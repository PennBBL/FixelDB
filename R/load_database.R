# this script contains code that initialises the Fixel HDF5 database

print("Initialising MariaDB database through Docker")

create_fixelDB <- function(index_file, directions_file, cohort_file, output_h5 = 'fixeldb.h5',
                          relative_root='/', img_name = "fixeldb") {
  
  # check if the image already exists
  docker <- stevedore::docker_client()
  
  img_exists <- image_available(name, tag, docker)
  
  if(!img_exists){
    
    message("Docker image not found locally! Pulling from Dockerhub")  
    docker$image$pull(name = name, tag = tag)
    
  }
  
  command = glue::glue(
    "run -ti --name {container_name} {ifelse(remove_img, '--rm', '')}",
    #"-e MYSQL_ROOT_PASSWORD={mysql_root_password}",
    #"-e MYSQL_DATABASE={mysql_database}",
    #"-e MYSQL_USER={mysql_user}",
    #"-e MYSQL_PASSWORD={mysql_password}",
    #"-v {paste0(volume_mounts, collapse=' -v ')}",
    "{ifelse(detach_img, '-d', '')}",
    "{name}:{tag}", .sep = " ")
  
  # run the docker command
  out <- system2("docker", command)
  
  # ensure it worked
  if(out != 0){
    message("Error creating FixelDB!")
  } else {
    
  }
  
}

read_fixelDB <- function(h5_file, cohort_file){
  
  dat <- rhdf5::H5Fopen(h5_file)
  
  cohort_df <- readr::read_csv(cohort_file)
  
  x <- list(data = dat, cohort = cohort_df)
  
  class(x) <- "fixelDB"
  
  x
  
}


# to read attributes -> rhdf5::h5readAttributes("/storage/fixel_stats_testing/fixel_components.h5", "results/has_names")
