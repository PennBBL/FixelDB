### Implement Seed Class

# class definition

setClass(
  "FixelArraySeed",
  contains = "HDF5ArraySeed",
  slots = c(
    filepath = "character",
    name = "character"
  )
)

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

### Implement Array based on seed

setClass("FixelArray",
  contains="DelayedArray",
  slots = c(
    fixels="HDF5Array",
    voxels="HDF5Array",
    results="NULL",
    subjects="list",
    scalars="list",
    path="character"
  )
)

#' Create a fixel array data type for fixel-based analysis in R
#'
#' @param filepath The HDF5 file created with Docker
#' @param scalar_types A list of expected scalars, can be extracted from your cohort file
#' @return A FixelArray object

FixelArray <- function(filepath, scalar_types = c("FD")) {
  
  fixel_data <- FixelArraySeed(filepath, name = "fixels", type = NA) %>%
    DelayedArray::DelayedArray()
  
  voxel_data <- FixelArraySeed(filepath, name = "voxels", type = NA) %>%
    DelayedArray::DelayedArray()
  
  ids <- vector("list", length(scalar_types))
  
  scalar_data <- vector("list", length(scalar_types))
  
  for(x in 1:length(scalar_types)){
    
    scalar_data[[x]] <- FixelArraySeed(filepath, name = sprintf("scalars/%s/values", scalar_types[x]), type = NA) %>%
      DelayedArray::DelayedArray()
    
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

### How does it print?

setMethod("show", "FixelArray", function(object) {
  
  cat(is(object)[[1]], " located at ", object@path, "\n\n",
      format("  Fixel data:", justify = "left", width = 20), dim(fixels(object))[1], " fixels\n",
      format("  Voxel data:", justify = "left", width = 20), dim(voxels(object))[1], " fixels\n",
      format("  Subjects:", justify = "left", width = 20), dim(subjects(object)[[1]])[2], "\n",
      format("  Scalars:", justify = "left", width = 20), names(scalars(object)), "\n",
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
setMethod("scalars", "FixelArray", function(x, ...) {
  
    dots <- list(...)
    
    if(length(dots) == 1) {
      
      scalar <- dots[[1]]
      x@scalars[[scalar]]
    
    } else {

      x@scalars
      
    }
    
  
  }
)

setGeneric("results", function(x) standardGeneric("results"))
setMethod("results", "FixelArray", function(x){
  
  scales <- scalars(x)
  
  for(scale in scales){
    
    print()
    
  }
  if(is.null(x@results)){
    
    return("No analysis results yet.")
    
  }
  
  else(x@results)

})

setGeneric("WriteResult", function(x, df, scalar) standardGeneric("WriteResult"))
setMethod("WriteResult", "FixelArray", function(x, df, scalar){
  
  rhdf5::h5write(obj = df, file = x@path, name = glue::glue("results/results_matrix"), write.attributes=TRUE)
  
  message("Results successfully written to HDF5 file. You can now view these results on a brain map with mrtrix!")

})

# print.FixelArray <- function(fa){
#   show(fa)
# }

summary.FixelArray <- function(data){
  
  scales <- scalars(data)
  
  for(scale in 1:length(scales)){
    
    cat(
      names(scales)[[scale]], ":\n"
      
    )

  }
  
}
