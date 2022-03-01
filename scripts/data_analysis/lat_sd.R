################## This function evaluates the standard deviation between the outputs of the 4 models ###################

## List of the maximal time coverage for each of the four models ------------------------------------------------------

MaxTime <- c("Scotese2" = 540,
             "Matthews" = 410,
             "Golonka" = 540, #rounded to 540 (instead of 544) for Golonka
             "Seton" = 200)  #the maximum time we want to reach, we basically go as far as the model goes


assess_sd <- function(thr){
  df1 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", models[[1]], '.RDS')) #models list created in the "cells_to_drop.R" file
  df2 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", models[[2]], '.RDS'))
  df3 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", models[[3]], '.RDS'))
  df4 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", models[[4]], '.RDS'))
  
  
  #spatial scaling
  
  df1[MAX, ] = NA  #MAX returned by the "cells_to_drop.R" script
  df2[MAX, ] = NA
  df3[MAX, ] = NA
  df4[MAX, ] = NA
  
  #temporal scaling: we create 3 three-dimensional combinations of arrays for different time slices so we don't end up assessing sd with NAs (that returns a NA)
    #we combine the 2-dimensional arrays in one 3D array (along = 3) for which we'll assess sd
  comb_array4 <- abind(df1[, 1:42], df2[, 1:42], df3[, 1:42], df4[, 1:42], along = 3) #from 10 to 200Ma (4models)
  comb_array3 <- abind(df1[, 43:84], df2[, 43:84], df3[, 43:84], along = 3) #from 210 to 410 (3 models: all except Seton)
  comb_array2 <- abind(df1[, 85:110], df3[, 85:110], along = 3) #from 420 to 540 (2 models: Scotese and Golonka, Matthews eliminated)
  
  
  #Standard deviation assessment on the 3 arrays
  
  SD4 <- apply(comb_array4, 
               MARGIN = c(1,2), #on the 2 dimensions of the resulting array 
               FUN = sd) #we apply the sd function
  
  SD3 <- apply(comb_array3, 
               MARGIN = c(1,2), 
               FUN = sd)
  
  SD2 <- apply(comb_array2, 
               MARGIN = c(1,2),
               FUN = sd)
  
  
  #Values under the threshold thr eliminated from the 3 arrays
  
  for(col in 1:(ncol(SD4)-2)){
    under_thresh <- which(SD4[, col+2] <= thr) #target the elements of SD inferior to threshold
    SD4[under_thresh, col] <- NA
  }
  
  
  for(col in 1:(ncol(SD3)-2)){
    under_thresh <- which(SD3[, col+2] <= thr) #target the elements of SD inferior to threshold
    SD3[under_thresh, col] <- NA
  }
  
  
  for(col in 1:(ncol(SD2)-2)){
    under_thresh <- which(SD2[, col+2] <= thr) #target the elements of SD inferior to threshold
    SD2[under_thresh, col] <- NA
  }
  
  
  #Arrays finally re-assembled
  
  SD <- cbind(SD4, SD3, SD2)
  return(SD)
}

thr = 0.5

SD <- assess_sd(thr = thr)
SD_df <- data.frame(SD)
#we get the initial coordinates of the spatial data points (as subtracting two dfs makes them = 0, which is annoying)
coords_ref <- readRDS('./data/extracted_paleocoordinates/Scotese2.RDS')[,1:2]
SD_df[, 1:2] <- coords_ref
saveRDS(SD_df, "./data/standard_deviation_4mdls.RDS")


