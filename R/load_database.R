# this script contains code that initialises the Fixel HDF5 database

# CreateFixelArrayFile <- function(index_file, directions_file, cohort_file, output_h5 = 'fixels.h5',
#                           relative_root='/', img_name = "pennbbl/fixeldb", remove_img = TRUE, detach_img = TRUE) {
#   
#   # check if the image already exists
#   docker <- stevedore::docker_client()
#   
#   img_exists <- docker_available(img_name, tag="latest", docker)
#   
#   if(!img_exists){
#     
#     message("Docker image not found locally! Pulling from Dockerhub")  
#     docker$image$pull(name = img_name, tag = "latest")
#     
#   }
#   
#   command = glue::glue(
#     "docker run -ti --name fixelarray {ifelse(remove_img, '--rm', '')}",
#     "{ifelse(detach_img, '-d', '')}",
#     "{img_name}:latest", .sep = " ")
#   
#   # run the docker command
#   out <- system2("echo", command)
#   
#   # ensure it worked
#   if(out != 0){
#     message("Error creating FixelArray File!")
#   } else {
#     message("FixelArray file created")
#   }
#   
# }
# 
# 
# # to read attributes -> rhdf5::h5readAttributes("/storage/fixel_stats_testing/fixel_components.h5", "results/has_names")
