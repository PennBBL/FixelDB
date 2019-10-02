import numpy as np
import nibabel as nb
import pandas as pd

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

    fixel_table = pd.DataFrame(
        dict(
            fixel_id=fixel_ids,
            voxel_id=fixel_voxel_ids))

    return fixel_table, voxel_table
