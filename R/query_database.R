# this script contains code that queries the database for fixel data

# a function to query for a specific fixel ID
# get_fixel_values <- function(fixel_data, fixel_id){
#   
#   scalars <- fixel_data$cohort$scalar_name %>%
#     unique()
#   
#   subjects <- fixel_data$cohort$subject_id
#   
#   df <- data.frame(subject = subjects, fixel_id = fixel_id)
#   
#   for(x in 1:length(scalars)){
#     
#     col <- fixel_data$data$scalars[[x]]$values[fixel_id,] %>%
#       data.frame()
#     
#     names(col) <- scalars[[x]]
#     
#     df <- dplyr::bind_cols(list(df, col))
#     
#   }
#   
#   df
#   
# }
# 
# # a function to get the number of fixels
# 
