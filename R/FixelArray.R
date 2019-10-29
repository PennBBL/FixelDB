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
  
  seed = HDF5Array::HDF5ArraySeed(
    filepath, name = name, type = type)
  
  seed
  
}

### Implement Array based on seed

setClass("FixelArray",
  contains="DelayedArray",
  slots = c(
    fixels="HDF5Array",
    voxels="HDF5Array",
    scalars="list"
  )
)

FixelArray <- function(filepath, scalar_types = "FD") {
  
  fixel_data <- FixelArraySeed(filepath, name = "fixels", type = NA) %>%
    DelayedArray::DelayedArray()
  
  voxel_data <- FixelArraySeed(filepath, name = "voxels", type = NA) %>%
    DelayedArray::DelayedArray()
  
  scalar_data <- vector("list", length(scalar_types))
  
  for(x in 1:length(scalar_types)){
    
    scalar_data[[x]] <- FixelArraySeed(filepath, name = sprintf("scalars/%s/values", scalar_types[x]), type = NA) %>%
      DelayedArray::DelayedArray()
  }
  
  names(scalar_data) <- scalar_types
  
  new(
    "FixelArray",
    fixels = fixel_data,
    voxels = voxel_data,
    scalars = scalar_data
    )

}

### How does it print?

setMethod("show", "FixelArray", function(object) {
  
  cat(is(object)[[1]], "\n",
      "  Fixel data: ", dim(fixels(object))[1], " individual fixels\n",
      "  Voxel data:  ", dim(voxels(object))[1], " voxels\n",
      "  Subjects: ", dim(scalars(x)[[1]])[2], "\n",
      "  Scalars: ", names(scalars(x)),
      sep = ""
  )

})

setGeneric("fixels", function(x) standardGeneric("fixels"))
setMethod("fixels", "FixelArray", function(x) x@fixels)

setGeneric("voxels", function(x) standardGeneric("voxels"))
setMethod("voxels", "FixelArray", function(x) x@voxels)

setGeneric("scalars", function(x, ...) standardGeneric("scalars"))
setMethod("scalars", "FixelArray", function(x, ...) {
  
    dots <- list(...)
    
    if(length(dots) > 0) {
    
      for(d in dots) {
        
        print(x@scalars[[d]])
        
      }
      
    } else {
      
      x@scalars
      
    }
  }
)