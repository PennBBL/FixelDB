# this file contains all of the checks that are necessary for the package to work



# docker_available <- function(name, tag, docker_client){
#   
#   # this function makes sure the docker image is available 
#   
#   search_result <- docker_client$image$list() %>%
#     dplyr::as_tibble() %>%
#     tidyr::unnest(repo_tags) %>%
#     filter(stringr::str_detect(repo_tags, glue::glue("{name}:{tag}")))
#   
#   ifelse(
#     nrow(search_result) > 0, 
#     return(TRUE), 
#     return(FALSE)
#   )
#   
# }
