############ This script processes and pools the rotated occurrences into one dataset ##############


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Library -----------------------------------------------------------------------
library(rgdal)

## Pre-processing ----------------------------------------------------------------
dir <- "C:/Users/lucas/OneDrive/Bureau/Internship_2022/project/rotated_fossils/" #the directory where you stored the output shapefiles
models <- c("Golonka", "Seton", "Matthews", "Scotese")
MaxT <- list("Golonka" = 235,
             "Seton" = 195,
             "Matthews" = 235,
             "Scotese"  = 235)


## This loop is basically an adapted version of the "rotating.R" one -------------
for(mdl in models){
  for(taxon in c("Corals", "Crocos")){
    time_bin <- readRDS(paste0('./data/occurrences/cleaned_', taxon, '_dataset.RDS'))$bin_mid_ma
    
    #create a dataset that will contain the cordinates of the rotated occurrences at the time they were living
    coords_over_time <- data.frame(TB = time_bin)
    
    #for some reason, the column of the lat at t=0 doesn't want to be included, even when we force it....
    
    for(t in c(seq(from = 5, to = MaxT[[mdl]], by = 10))){
      ectory <- paste0(dir, mdl, "/", taxon, "/", taxon, "_to_rotate/reconstructed_", t, ".00Ma.shp")
      
      shape <- shapefile(x = ectory) #shapefile of the corresonding model at the corresponding time
      df <- as.data.frame(shape)  #we convert the shapefile into a dataframe, therefore containing the paleocoordinates of the spatial data points
      
      index <- t/5 #the column index (t/10 as we have a 10My step, multiplied by 2 as two features per step: lat and lon)
      coords_over_time[,index+1] <- df$coords.x1 #we store these paleocoordinates in coords_over_time
      names(coords_over_time)[index+1] <- paste0("lon_", t)
      
      coords_over_time[,index+2] <- df$coords.x2
      names(coords_over_time)[index+2] <- paste0("lat_", t)
      
      #cleaning species for which we have a coordinate at t whereas we shouldn't
      to_drop <- which(time_bin != t) #indexes of the species that absent at time t (except for 0)
      coords_over_time[to_drop, index+1] <- NA
      coords_over_time[to_drop, index+2] <- NA
    }
    
    if(mdl == "Seton"){ #extend Seton time range
      for(t in seq(from = 205, to = 235, by = 10)){
        coords_over_time[, (t/5)+1] = NA
        names(coords_over_time)[(t/5)+1] <- paste0("lon_", t)
        
        coords_over_time[, (t/5)+2] = NA
        names(coords_over_time)[(t/5)+2] <- paste0("lat_", t)
      }
    }
    
    path <- "./data/fossil_extracted_paleocoordinates/"
    saveRDS(object = coords_over_time, 
            file = paste0(path, "/", taxon, "/", mdl, ".RDS")) #we finally export the coordinates over time as .RDS file
  }
}

