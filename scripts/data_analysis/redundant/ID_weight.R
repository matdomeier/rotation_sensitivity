################### This script is to assess the differences between the models in terms of plateID #####################

#nb: Seton excluded from this analysis

store <- readRDS('./data/georeferenced/Scotese2.RDS')[, c(1,2,8)] #store will be the dataframe containing the plate ID assigned to each point according to the 3 models (all without Seton)
without_seton <- models[-c(4)]
i = 1
while(i < length(without_seton)){
  i = i+1
  store[,i+2] <- readRDS(paste0('./data/georeferenced/', models[i], '.RDS'))$georef
}
colnames(store) <- c("lon_0", "lat_0", "Scotese2_ID", "Matthews_ID", "Golonka_ID")

store <- store[-MAX,] #we get rid of the points we don't want to work on (MAX defined in the "cells_to_drop.R" script)

# Assess the ID_weight, the metric quantifying the number of different plate IDs a point has been assigned to according to the 3 models
store$ID_weight <- 0
for(id in 1:nrow(store)){
  store$ID_weight[id] <- length(unique(as.numeric(store[id,3:5])))  #the length of the plateID row without duplicates
}

saveRDS(store, file = "./data/data_pts_plate_IDs_according_to_the_four_models.RDS")
