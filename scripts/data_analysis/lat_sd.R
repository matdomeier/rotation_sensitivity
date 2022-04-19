################## This function evaluates the standard deviation between the outputs of the 4 models (lat and lon) ###################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com

## Library ------------------------------------------------------------------------------------------------------------

library(abind)


## List of the maximal time coverage for each of the four models ------------------------------------------------------

MaxTime <- c("Scotese2" = 540,
             "Matthews" = 410,
             "Wright" = 540, #rounded to 540 (instead of 544) for Wright
             "Seton" = 200)  #the maximum time we want to reach, we basically go as far as the model goes

## Function to assess longitudinal sd after correcting by wrapping ----------------------------------------------------
sd_unwrap <- function(set_pts){
  if((0 < length(which(set_pts < 0))) & (length(which(set_pts < 0)) < length(set_pts))){ #if there is at least 1 and at up to 3 (=length(set_pts-1)) negative (i.e different signs, which can cause troubles)
    ref = max(set_pts[which(set_pts < 0)])
    for(i in 1:length(set_pts)){
      if(set_pts[i] <= 0){ #negative
        set_pts[i] <- abs(set_pts[i]-ref)
      }
      else{ #positive
        set_pts[i] <- abs(set_pts[i] - 180) + abs(180 + ref)
      }
    }
  }
  return(sd(set_pts))
}

## Big sd function ----------------------------------------------------------------------------------------------------
assess_sd <- function(metric, thr){
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
  if(metric == "lat"){
    comb_array4 <- abind(df1[, seq(from = 2, to = 42, by = 2)], df2[, seq(from = 2, to = 42, by = 2)], df3[, seq(from = 2, to = 42, by = 2)], df4[, seq(from = 2, to = 42, by = 2)], along = 3) #from 10 to 200Ma (4models)
    comb_array3 <- abind(df1[, seq(from = 44, to = 84, by = 2)], df2[, seq(from = 44, to = 84, by = 2)], df3[, seq(from = 44, to = 84, by = 2)], along = 3) #from 210 to 410 (3 models: all except Seton)
    comb_array2 <- abind(df1[, seq(from = 86, to = 110, by = 2)], df3[, seq(from = 86, to = 110, by = 2)], along = 3) #from 420 to 540 (2 models: Scotese and Wright, Matthews eliminated)
    
    
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
    
  }
  
  else if(metric == "lon"){
    comb_array4 <- abind(df1[, seq(from = 1, to = 41, by = 2)], df2[, seq(from = 1, to = 41, by = 2)], df3[, seq(from = 1, to = 41, by = 2)], df4[, seq(from = 1, to = 41, by = 2)], along = 3) #from 10 to 200Ma (4models)
    comb_array3 <- abind(df1[, seq(from = 43, to = 83, by = 2)], df2[, seq(from = 43, to = 83, by = 2)], df3[, seq(from = 43, to = 83, by = 2)], along = 3) #from 210 to 410 (3 models: all except Seton)
    comb_array2 <- abind(df1[, seq(from = 85, to = 109, by = 2)], df3[, seq(from = 85, to = 109, by = 2)], along = 3) #from 420 to 540 (2 models: Scotese and Wright, Matthews eliminated)
      
    #Standard deviation assessment on the 3 arrays corrected by the longitudinal wrapping
    
    SD4 <- apply(comb_array4, 
                 MARGIN = c(1,2), #on the 2 dimensions of the resulting array 
                 FUN = sd_unwrap) #we apply the sd function
    
    SD3 <- apply(comb_array3, 
                 MARGIN = c(1,2), 
                 FUN = sd_unwrap)
    
    SD2 <- apply(comb_array2, 
                 MARGIN = c(1,2),
                 FUN = sd_unwrap)

  }
  
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
  SD_df <- data.frame(SD)
  
  return(SD_df)
}


## Execute -------------------------------------------------------------------------------------------------
coords_ref <- readRDS('./data/extracted_paleocoordinates/Scotese2.RDS')[,1:2] #we get the initial coordinates of the spatial data points (as subtracting two dfs makes them = 0, which is annoying)
thr = 0.5

    #Assess lat and lon sds
lon <- assess_sd(metric = "lon", thr)
lat <- assess_sd(metric = "lat", thr)

  #We merge the 2 dataframes by alternating columns
new_order <- order(c(2*(seq_along(lon)-1)+1, 2*seq_along(lat)))
final <- cbind(lon, lat)[, new_order]
final[, 1:2] <- coords_ref
saveRDS(final, file = "./data/standard_deviation_4mdls.RDS")
