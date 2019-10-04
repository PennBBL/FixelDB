import numpy as np
import nibabel as nb
import pandas as pd
from tqdm import tqdm
import sqlalchemy as sa

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

    index_img = nb.load(index_file)
    index_data = index_img.get_data()
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

    directions_img = nb.load(directions_file)
    directions_data = directions_img.get_data().squeeze()

    fixel_table = pd.DataFrame(
        dict(
            fixel_id=fixel_ids,
            voxel_id=fixel_voxel_ids,
            x = directions_data[:,0],
            y = directions_data[:,1],
            z = directions_data[:,2])
        )

    return fixel_table, voxel_table

def upload_cohort(index_file, directions_file, cohort_file):
    """
    Load all fixeldb data.

    Parameters
    -----------

    index_file: str
        path to a Nifti2 index file
    directions_file: str
        path to a Nifti2 directions file
    """
    # define engine
    engine = sa.create_engine('mysql+pymysql://fixeluser:fixels@localhost:3306/fixeldb')

    # gather fixel data
    fixel_table, voxel_table = gather_fixels(index_file, directions_file)

    # upload fixel data
    voxel_table.to_sql('voxels', engine, index=False, if_exists="replace")
    fixel_table.to_sql('fixels', engine, index=False, if_exists="replace")

    # gather cohort data
    cohort_df = pd.read_csv(cohort_file)

    # upload each cohort's data
    for ix, row in tqdm(cohort_df.iterrows(), total=cohort_df.shape[0]):


        scalar_img = nb.load(row.nifti2_file)
        scalar_data = scalar_img.get_data().squeeze()
        scalar_df = pd.DataFrame(
            {"value": scalar_data, "_id": ix}
        )

        # upload here
        scalar_df.to_sql(row.scalar_name, engine, index_label='fixel_id', if_exists="append")

        pheno = row.to_dict()
        del pheno['scalar_name']
        del pheno['nifti2_file']

        pheno["_id"] = ix
        pheno_df = pd.DataFrame([pheno])
        pheno_df.to_sql('phenotypes', engine, index=False, if_exists="append")

    return 0
