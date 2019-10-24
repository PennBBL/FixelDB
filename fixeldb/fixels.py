import argparse
import shutil
import os
from collections import defaultdict
import os.path as op
import tempfile
import subprocess
import numpy as np
import nibabel as nb
import pandas as pd
from tqdm import tqdm
import h5py

def find_mrconvert():
    program = 'mrconvert'

    def is_exe(fpath):
        return os.path.exists(fpath) and os.access(fpath, os.X_OK)

    for path in os.environ["PATH"].split(os.pathsep):
        path = path.strip('"')
        exe_file = os.path.join(path, program)
        if is_exe(exe_file):
            return program
    return None


def mif_to_nifti2(mif_file):

    if not mif_file.endswith(".nii"):
        dirpath = tempfile.mkdtemp()
        mrconvert = find_mrconvert()
        if mrconvert is None:
            raise Exception("The mrconvert executable could not be found on $PATH")
        nii_file = op.join(dirpath, 'mif.nii')
        proc = subprocess.Popen([mrconvert, mif_file, nii_file], stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        _, err = proc.communicate()
    else:
        nii_file = mif_file
        dirpath = None
    if not op.exists(nii_file):
        raise Exception(err)
    nifti2_img = nb.load(nii_file)
    data = nifti2_img.get_data().squeeze()
    # ... do stuff with dirpath
    if dirpath:
        shutil.rmtree(dirpath)
    return nifti2_img, data


def gather_fixels(index_file, directions_file):
    """
    Load the index and directions files to get lookup tables.

    Parameters
    -----------

    index_file: str
        path to a Nifti2 index file
    directions_file: str
        path to a Nifti2 directions file
    """

    index_img, index_data = mif_to_nifti2(index_file)
    count_vol = index_data[..., 0]
    id_vol = index_data[..., 1]
    max_id = id_vol.max()
    max_fixel_id = max_id + int(count_vol[id_vol == max_id])
    voxel_mask = count_vol > 0
    masked_ids = id_vol[voxel_mask]
    masked_counts = count_vol[voxel_mask]
    id_sort = np.argsort(masked_ids)
    sorted_counts = masked_counts[id_sort]
    voxel_coords = np.column_stack(np.nonzero(count_vol))

    fixel_id = 0
    fixel_ids = np.arange(max_fixel_id, dtype=np.int32)
    fixel_voxel_ids = np.zeros_like(fixel_ids)
    for voxel_id, fixel_count in enumerate(sorted_counts):
        for _ in range(fixel_count):
            fixel_voxel_ids[fixel_id] = voxel_id
            fixel_id += 1
    sorted_coords = voxel_coords[id_sort]

    voxel_table = pd.DataFrame(
        dict(
            voxel_id=np.arange(voxel_coords.shape[0]),
            i=sorted_coords[:, 0],
            j=sorted_coords[:, 1],
            k=sorted_coords[:, 2]))

    directions_img, directions_data = mif_to_nifti2(directions_file)
    fixel_table = pd.DataFrame(
        dict(
            fixel_id=fixel_ids,
            voxel_id=fixel_voxel_ids,
            x=directions_data[:,0],
            y=directions_data[:,1],
            z=directions_data[:,2])
        )

    return fixel_table, voxel_table


def write_hdf5(index_file, directions_file, cohort_file, output_h5='fixeldb.h5',
               relative_root='/'):
    """
    Load all fixeldb data.

    Parameters
    -----------

    index_file: str
        path to a Nifti2 index file
    directions_file: str
        path to a Nifti2 directions file
    cohort_file: str
        path to a csv with demographic info and paths to data
    relative_root: str
        path to which index_file, directions_file and cohort_file (and its contents) are relative
    """
    # gather fixel data
    fixel_table, voxel_table = gather_fixels(op.join(relative_root, index_file),
                                             op.join(relative_root, directions_file))

    # gather cohort data
    cohort_df = pd.read_csv(op.join(relative_root, cohort_file))

    # upload each cohort's data
    scalars = defaultdict(list)
    subject_lists = defaultdict(list)
    for ix, row in tqdm(cohort_df.iterrows(), total=cohort_df.shape[0]):
        print(row)

        scalar_file = op.join(relative_root, row.scalar_mif)
        scalar_img, scalar_data = mif_to_nifti2(scalar_file)
        scalars[row['scalar_name']].append(scalar_data)
        subject_lists[row['scalar_name']].append(ix)

    # Write the output
    output_file = op.join(relative_root, output_h5)
    f = h5py.File(output_file, "w")
    f.create_dataset(name="fixels", data=fixel_table.to_numpy().T)
    f.create_dataset(name="voxels", data=voxel_table.to_numpy().T)
    for scalar_name in scalars.keys():
        f.create_dataset('scalars/{}/values'.format(scalar_name),
                         data=np.row_stack(scalars[scalar_name]))
        f.create_dataset('scalars/{}/ids'.format(scalar_name),
                         data=np.row_stack(subject_lists[scalar_name]))
    f.close()
    return int(op.exists(output_file))


def get_parser():

    parser = argparse.ArgumentParser(
        description="Create a hdf5 file of fixel data")
    parser.add_argument(
        "--index-file", "--index_file",
        help="Index File",
        required=True)
    parser.add_argument(
        "--directions-file", "--directions_file",
        help="Index File",
        required=True)
    parser.add_argument(
        "--cohort-file", "--cohort-file",
        help="Index File",
        required=True)
    parser.add_argument(
        "--relative-root", "--relative_root",
        help="Root to which all paths are relative",
        type=os.path.abspath)
    parser.add_argument(
        "--output-hdf5", "--output_hdf5",
        help="hdf5 file where outputs will be saved.")
    return parser


def main():

    parser = get_parser()
    args = parser.parse_args()
    status = write_hdf5(index_file=args.index_file,
                        directions_file=args.directions_file,
                        cohort_file=args.cohort_file,
                        output_h5=args.output_hdf5,
                        relative_root=args.relative_root)
    return status


if __name__ == "__main__":
    main()
