### ========================
### FixelArraySeed objects
### ----------------------

print("hello-world")

# "NiftiArrayList" class
#
# @name NiftiArrayList-class
# @family NiftiArrayList
#
#setOldClass("NiftiArrayList")


# @importClassesFrom HDF5Array HDF5ArraySeed
# @aliases DelayedArray, FixelArraySeed-method
# @exportClass FixelArraySeed
# @rdname FixelArraySeed

### Set the class
# setClass(
#   "FixelArraySeed",
#   contains = "HDF5ArraySeed",        #inherits from
#   slots = c(
#     filepath = "character",
#     name = "character"
#   )
# )

#' Constructor Function for class


# @importClassesFrom HDF5Array HDF5Array
# @rdname FixelArray
# @exportClass FixelArray
# setClass(
#   "FixelArray",
#   contains = "HDF5Array",
#   slots = c(
#     seed = "FixelArraySeed"#,
#     # fixels = "HDF5Array",
#     # voxels = "HDF5Array",
#     # scalars="list",
#     # subjects="list"
#   )
# )
# 


# NiftiMatrix Class
#
# @importClassesFrom DelayedArray DelayedMatrix
# @rdname NiftiMatrix
#
# @return A `NiftiMatrix` object.
# @exportClass NiftiMatrix
# setClass("NiftiMatrix", contains = c("NiftiArray", "DelayedMatrix"))



# Seed for FixelArray Class
# TODO: fix description
# @param filepath The path (as a single character string) to the NIfTI or HDF5
#  file where the dataset is located. If a path to the NIfTI is provided we call
#  [RNifti::readNifti()] and [NiftiArray::writeNiftiArray()] to convert to the HDF5
#  and more memory and time are used. If a path to a HDF5 file the data is simply loaded
#  into R as an object of class [NiftiArray]. A path to the HDF5 file is more memory and time efficient.
# @param name The name of the group for the NIfTI image in the HDF5 file. Default is set to "image".
# Unless you have to other "image" groups in the HDF5 file there is no need to change default settings.
# @param header_name The name of the group for the NIfTI header in the HDF5 file. Default is set to "header".
# Unless you have to other "header" groups in the HDF5 file there is no need to change default settings.
# @param type `NA` or the R atomic type, passed to
# [HDF5Array::HDF5Array()] corresponding to the type of the HDF5 dataset. Default is set to `NA`.
# Unless you want different types of HDF5 storage files there is no need to change default settings.
# @param header List of NIfTI header information to override call of
# [nifti_header].
#
# @return A `FixelArraySeed` object
# @export
# @importFrom HDF5Array HDF5ArraySeed
# @importFrom rhdf5 h5read
# @importFrom S4Vectors new2
# @examples
# nii_fname = system.file("extdata",
# "example.nii.gz", package = "RNifti")
# res = NiftiArraySeed(nii_fname)
# hdr = nifti_header(res)
# res2 = NiftiArraySeed(nii_fname, header = hdr)

