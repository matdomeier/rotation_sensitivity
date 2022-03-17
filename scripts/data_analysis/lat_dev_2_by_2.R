################## This function evaluates the absolute difference between the outputs of the 2 mdls #################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


##In addition, all difference under the threshold thr will be set to NA


## List of the maximal time coverage for each of the four models ------------------------------------------------------

MaxTime <- c("Scotese2" = 540,
             "Matthews" = 410,
             "Wright" = 540, #rounded to 540 (instead of 544) for Golonka
             "Seton" = 200)  #the maximum time we want to reach, we basically go as far as the model goes


## Function ------------------------------------------------------------------------------------------------------------

assess_diff <- function(mdl1, mdl2, thr){
  
  df1 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", mdl1, '.RDS')) #open the datasets containing the paleocoordinates over time of the corresponding models
  df2 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", mdl2, '.RDS')) #and erase the first column, residual indexes with no interest
  
  #select the temporal coverage of the model that has the minimal one
  t1 <- MaxTime[[mdl1]]
  t2 <- MaxTime[[mdl2]]
  
  chosen_time <- min(t1, t2)
  
  #temporal scaling (as far as the model with the minimal temporal coverage goes)
  df1 <- df1[, seq(from = 1, to = 2*(chosen_time/10 + 1), by = 1)]
  df2 <- df2[, seq(from = 1, to = 2*(chosen_time/10 + 1), by = 1)]
  
  #spatial scaling (same points as the model that covers the minimal number of points)
  df1[MAX, ] = NA #MAX defined in the "cells_to_drop.R" file
  df2[MAX, ] = NA
  
  #difference assessment
  difference <- abs(df1-df2)
  
  #all difference values under the threshold set to NA
  for(k in 1:ncol(difference)){
    under_thresh <- which(difference[,k] < thr) #index of the values under the threshold
    difference[under_thresh, k] <- NA #these values set to NA
  }
  
  difference[,1:2] = coords_ref
  return(difference)
}


#while loop to run the functions comparing the outputs of each model 2 by 2 (avoiding to compare twice the same models and also not comparing a model with itself)
models_copy = models #defined in "cells_to_drop.R"
i = 1
thr = 0.5 #all values under 0.5 degrees will be considered as unsignificant change

while(i <= length(models)){
  mdl1 <- models[[i]]
  for(mdl2 in models_copy){
    if(mdl1 != mdl2){
      difference <- assess_diff(mdl1, mdl2, thr)
      saveRDS(difference, 
              file = paste0("./data/latitude_deviation_2_by_2/", mdl1, '_', mdl2, 'diff.RDS'))
    }
  }
  models_copy = models_copy[-1]  #we get rid of the new first element
  i = i+1
}
