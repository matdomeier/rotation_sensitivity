################### This script is to assess the differences between the models in terms of plateID #####################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


#nb: Seton excluded from this analysis

store <- xy[, 1:2] #store will be the dataframe containing the plate ID assigned to each point according to the 3 models (all without Seton)
colnames(store) <- c("lon_0", "lat_0")
without_seton <- models[-which(models == "Seton")]
for(mdl in without_seton){
  store[,c(mdl)] <- readRDS(paste0('./data/georeferenced/', mdl, '.RDS'))$georef
}


store <- store[-MAX,] #we get rid of the points we don't want to work on (MAX defined in the "cells_to_drop.R" script)

# Assess the ID_score, the metric quantifying the number of different plate IDs a point has been assigned to according to the 3 models
store$ID_score <- 0
for(id in 1:nrow(store)){
  store$ID_score[id] <- length(unique(as.numeric(store[id,3:5])))  #the length of the plateID row without duplicates
}

saveRDS(store, file = "./data/data_pts_plate_IDs_according_to_the_four_models.RDS")
