################## This function evaluates the standard deviation between the outputs of the 4 models ###################

## List of the maximal time coverage for each of the four models ------------------------------------------------------

MaxTime <- c("Scotese2" = 540,
             "Matthews" = 410,
             "Golonka" = 540, #rounded to 540 (instead of 544) for Golonka
             "Seton" = 200)  #the maximum time we want to reach, we basically go as far as the model goes


assess_sd <- function(mdl_list){
  df1 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", mdl_list[[1]], '.RDS'))
  df2 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", mdl_list[[2]], '.RDS'))
  df3 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", mdl_list[[3]], '.RDS'))
  df4 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", mdl_list[[4]], '.RDS'))
  print(nrow(df4))
  
  chosen_time <- min(MaxTime)
  
  #spatial scaling
  
  df1[MAX, ] = NA  #MAX returned by the "cells_to_drop.R" script
  df2[MAX, ] = NA
  df3[MAX, ] = NA
  df4[MAX, ] = NA
  
  #temporal scaling
  
  df1 <- df1[, seq(from = 1, to = 2*(chosen_time/10 + 1), by = 1)]
  df2 <- df2[, seq(from = 1, to = 2*(chosen_time/10 + 1), by = 1)]
  df3 <- df3[, seq(from = 1, to = 2*(chosen_time/10 + 1), by = 1)]
  df3 <- df3[, seq(from = 1, to = 2*(chosen_time/10 + 1), by = 1)]
  
  
  comb_array <- abind(df1, df2, df3, df4, along = 3) #we combine the 2-dimensional arrays in one 3D array (along = 3) for which we'll assess sd
  SD <- apply(comb_array,
              MARGIN = c(1,2), #on the 2 dimensions of the resulting array
              FUN = sd) #we apply the sd function
  return(SD)
}
