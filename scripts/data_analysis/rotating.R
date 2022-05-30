############# This script processes the rotated shapefiles #################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


library(raster)


#### Read the data and extract the paleocoordinates model per model ####

models <- c("Scotese2",  #PALEOMAP latest version
            "Matthews",  
            "Wright",
            "Seton")

MaxTime <- c("Scotese2" = 540,
             "Matthews" = 410,
             "Wright" = 540,
             "Seton" = 200)  #the maximum time we want to reach, we basically go as far as the model goes
                 
dir0 <- "C:/Users/lucas/OneDrive/Bureau/Internship_2022/project" # DIRECTORY WHERE YOU STORED THE OUTPUT SHAPEFILES

#extraction loop
for(mdl in models){
  coords_over_time <- data.frame(lon_init = xy.df$x,   #xy.df object comes from the "build_grid.R" script
                                 lat_init = xy.df$y)   #in this dataframe, we'll store the evolution of the coordinates of the spatial points over time, given a model
  
  rownames(coords_over_time) = 1:nrow(coords_over_time)
  maxTime <- MaxTime[[mdl]]
  Timeframe <- seq(from = 10, to = maxTime, by = 10)   #from 10 to the maximal duration covered with a timestep of 10My (we don't consider 0 as we initialise our storing dataframe with initial coordianates, corresponding to 0)
  
  #create the name of the output datasets' columns (lon and lat for any time in Timeframe)
  names <- c("lon_0", "lat_0")
  
  for(t in Timeframe){
    print(t)
    names <- c(names, paste0("lon_", t), paste0("lat_", t))
    dir <- paste0(dir0, "/rotated_shapefiles_10My_intervals/", mdl, "/meshgrid/reconstructed_", t, ".00Ma.shp")
    shape <- shapefile(x = dir) #shapefile of the corresonding model at the corresponding time
    df <- as.data.frame(shape)  #we convert the shapefile into a dataframe, therefore containing the palaeocoordinates of the spatial data points
    
    index <- 2*t/10 #the column index (t/10 as we have a 10My step, multiplied by 2 as two features per step: lat and lon)
    coords_over_time[,c(index+1, index+2)] <- NA #we add two NA columns to the df (will further contain rotated cells)
    L_corr <- apply(X = df[, c("x", "y")], MARGIN = c(1), FUN = function(el){ #el is an element like c(lon, lat) (dim = 2)
      which((coords_over_time[, 1] == el[1]) & (coords_over_time[, 2] == el[2])) }) #list of the corresponding indexes for the cells of the rotated file in the reference (the two first columns of coords_over_time  )
    
    coords_over_time[L_corr, c(index+1, index+2)] <- df[, c("coords.x1", "coords.x2")]
  }
  colnames(coords_over_time) <- names
  path <- "./data/extracted_paleocoordinates/"
  saveRDS(object = coords_over_time, 
            file = paste0(path, mdl, ".RDS")) #we finally export the coordinates over time as .RDS file
}

