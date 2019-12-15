FixelArraySeed <- function(
  filepath,
  name = "fixels",
  type = NA) {

  if(all(
    c("fixels", "voxels", "scalars")
    %in%
    rhdf5::h5ls(filepath)$name
  )
  ) {

    seed = HDF5Array::HDF5ArraySeed(
      filepath, name = name, type = type)

    seed

  } else {

    stop("Improperly formatted Fixel data")

  }

}

setClass(
  "FixelArray",
  #contains="DelayedArray",
   slots = c(
     fixels="DelayedArray",
     voxels="DelayedArray",
     results="NULL",
     subjects="list",
     scalars="list",
     path="character"
   )
)

#' Load fixel data output from mrtrix as an h5 file into R as a FixelArray object
#'
#' @param filepath file
#' @param scalar_types expected scalars
#' @return FixelArray object
#' 

FixelArray <- function(filepath, scalar_types = c("FD")) {

  fixel_data <- FixelArraySeed(filepath, name = "fixels", type = NA) %>%
    DelayedArray::DelayedArray() %>%
    t()
  
  colnames(fixel_data) <- c("Fixel_id", "Voxel_id", "x", "y", "z")
  
  voxel_data <- FixelArraySeed(filepath, name = "voxels", type = NA) %>%
    DelayedArray::DelayedArray() %>%
    t()
  
  colnames(voxel_data) <- c("Voxel_id", "x", "y", "z")

  ids <- vector("list", length(scalar_types))

  scalar_data <- vector("list", length(scalar_types))

  for(x in 1:length(scalar_types)){

    scalar_data[[x]] <- FixelArraySeed(filepath, name = sprintf("scalars/%s/values", scalar_types[x]), type = NA) %>%
      DelayedArray::DelayedArray() %>%
      t()

    ids[[x]] <- FixelArraySeed(filepath, name = sprintf("scalars/%s/ids", scalar_types[x]), type = NA) %>%
      DelayedArray::DelayedArray()
  }

  names(scalar_data) <- scalar_types
  names(ids) <- scalar_types

  results <- NULL

  new(
    "FixelArray",
    fixels = fixel_data,
    voxels = voxel_data,
    subjects = ids,
    scalars = scalar_data,
    results = results,
    path = filepath
  )

}

# FixelMatrix <- function(fa){
#   
#   
# }

#' Write outputs from fixel-based analysis out to the h5 file
#'
#' @param fa FixelArray object
#' @param data A data.frame object with model results at each fixel
#' @param name Name assigned to the results table in the h5 file
#' 

writeResults <- function(fa, data, name = "results"){
  
  if(!("data.frame" %in% class(data))) {
    stop("Results dataset is not correct; must be data of type `data.frame`")
  }
  
  rhdf5::h5write(data, fa@path, name)
  
  message("Results file written!")
}

setMethod("show", "FixelArray", function(object) {

  cat(is(object)[[1]], " located at ", object@path, "\n\n",
      format("  Fixel data:", justify = "left", width = 20), dim(fixels(object))[1], " fixels\n",
      format("  Voxel data:", justify = "left", width = 20), dim(voxels(object))[1], " voxels\n",
      format("  Subjects:", justify = "left", width = 20), dim(subjects(object)[[1]])[1], "\n",
      format("  Scalars:", justify = "left", width = 20), paste0(names(scalars(object)), collapse = ", "), "\n",
      #format("  Analyses:", justify = "left", width = 20), results(object), "\n",
      sep = ""
  )

})


setGeneric("fixels", function(x) standardGeneric("fixels"))
setMethod("fixels", "FixelArray", function(x) x@fixels)

setGeneric("voxels", function(x) standardGeneric("voxels"))
setMethod("voxels", "FixelArray", function(x) x@voxels)

setGeneric("subjects", function(x) standardGeneric("subjects"))
setMethod("subjects", "FixelArray", function(x) x@subjects)

setGeneric("scalars", function(x, ...) standardGeneric("scalars"))
setMethod(
  "scalars",
  "FixelArray",
  function(x, ...) {

    dots <- list(...)

    if(length(dots) == 1) {

      scalar <- dots[[1]]
      x@scalars[[scalar]]

    } else {

      x@scalars

    }
  }
)