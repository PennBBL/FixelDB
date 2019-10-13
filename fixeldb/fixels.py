import argparse
import shutil
import os
import os.path as op
import tempfile
import subprocess
import numpy as np
import nibabel as nb
import pandas as pd
from tqdm import tqdm
import sqlalchemy as sa

"""
assumes you've started a db on docker like so:

docker run -ti --name mariadb1 --rm -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=fixeldb -e MYSQL_USER=fixeluser -e MYSQL_PASSWORD=fixels -d -v $PWD/login.py:/login.py pennbbl/fixeldb

for debugging you can enter the container with:

docker exec -it mariadb1 mariadb -u fixeluser -p
"""

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
    dirpath = tempfile.mkdtemp()
    mrconvert = find_mrconvert()
    if mrconvert is None:
        raise Exception("The mrconvert executable could not be found on $PATH")
    nii_file = op.join(dirpath, 'mif.nii')
    proc = subprocess.Popen([mrconvert, mif_file, nii_file], stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    _, err = proc.communicate()
    if not op.exists(nii_file):
        raise Exception(err)
    nifti2_img = nb.load(nii_file)
    data = nifti2_img.get_data().squeeze()
    # ... do stuff with dirpath
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
    fixel_ids = np.arange(max_fixel_id, dtype=np.int)
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
            x = directions_data[:,0],
            y = directions_data[:,1],
            z = directions_data[:,2])
        )

    return fixel_table, voxel_table

def upload_cohort(index_file, directions_file, cohort_file, relative_root='/'):
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
    # define engine
    engine = sa.create_engine('mysql+pymysql://fixeluser:fixels@localhost:3306/fixeldb')

    # gather fixel data
    fixel_table, voxel_table = gather_fixels(op.join(relative_root, index_file),
                                             op.join(relative_root, directions_file))

    # upload fixel data
    voxel_table.to_sql('voxels', engine, index=False, if_exists="replace")
    fixel_table.to_sql('fixels', engine, index=False, if_exists="replace")

    # gather cohort data
    cohort_df = pd.read_csv(op.join(relative_root, cohort_file))

    # upload each cohort's data
    for ix, row in tqdm(cohort_df.iterrows(), total=cohort_df.shape[0]):
        print(row)

        scalar_file = op.join(relative_root, row.scalar_mif)
        scalar_img, scalar_data = mif_to_nifti2(scalar_file)
        scalar_df = pd.DataFrame(
            {"value": scalar_data, "_id": ix}
        )

        # upload here
        scalar_df.to_sql(row.scalar_name, engine, index_label='fixel_id', if_exists="append")

        pheno = row.to_dict()
        del pheno['scalar_name']
        del pheno['scalar_mif']

        pheno["_id"] = ix
        pheno_df = pd.DataFrame([pheno])
        pheno_df.to_sql('phenotypes', engine, index=False, if_exists="append")

    return 0


def get_parser():

    parser = argparse.ArgumentParser(
        description="Set up a MariaDB instance of Fixel data")
    parser.add_argument(
        "--index-file",
        help="Index File",
        required=True
    )
    parser.add_argument(
        "--directions-file",
        help="Index File",
        required=True
    )
    parser.add_argument(
        "--cohort-file",
        help="Index File",
        required=True
    )
    parser.add_argument(
        "--relative-root", "--relative_root",
        help="Root to which all paths are relative",
        type=os.path.abspath
    )

    return parser


def main():

    parser = get_parser()
    args = parser.parse_args()

    status = upload_cohort(args.index_file, args.directions_file, args.cohort_file,
                           args.relative_root)
    return status


if __name__ == "__main__":
    main()
