#This script georeferences the coordinates of the grid with the spatial polygons of each rotation model
#This would enable us to attribute a plateID to each point.
#In the case of the models that only consider continental plates motion, the points in the oceans will just be attributed to no plateID


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Loading libraries ---------------------------------------------------------------------------------------------------
library(raster)



## BUILD THE GRID AGAIN ------------------------------------------------------------------------------------------------

r <- raster(res = 1) #start with a 1x1 raster
pos <- xyFromCell(object = r, cell = 1:ncell(r))  #extract coordinates as a df
xy <- data.frame(pos)

xy$Beginning <- 500 #500Ma ago, beginning of rotation
xy$End <- 0

xy.df <- SpatialPointsDataFrame(coords = xy[,1:2], data = xy)
proj4string(xy.df)<- CRS("+proj=longlat +datum=WGS84") #assign coord system to the SpatialPointsDataFrame



## Function to import models' polygons as shapefiles and proceed to the georeferencing ------------------------------------

get_na_pos <- function(mdl){
  #returns indexes of the pixels associated with non attributed plateIDs (plateID = NA)
  #In the terrestrial-only models, these points are the ocean plates. However, as not all model have the same plate boundaries, there might be discrepancies between the models
  #As plates are dynamic features in the Seton model, we didn't carried out the georeferencing on it
  
  if(mdl != "Seton"){
    dir <- paste0("./data/continental_polygons/",
                  mdl, "/",
                  mdl, "_PresentDay_ContinentalPolygons.shp")
    shape <- shapefile(dir) #we open the corresponding Gplates shapefile
    georef <- over(xy.df, shape)$PLATEID1  #georeferencing the spatial data points with the Gplates shp
    merged <- cbind.data.frame(xy.df, georef)  #merging both 
    
    #   NO NEED TO RUN THE LINE BELOW IF IT'S NOT THE FIRST TIME
    saveRDS(merged, file = paste0("./data/georeferenced/", mdl,".RDS"))  #get df with the assigned plate IDs
    
    indexes <- which(is.na(georef) == TRUE)
  }
  
  else { #plateIDs assignment complicated for Seton, so we just remove it from this part of the work
    indexes <- c()
  }
  
  return(indexes)
}


## Evaluating the indexes of the cells covered by all the 4 models ----------------------------------------------------------

MAX_raw <- lapply(X = models, FUN = get_na_pos)
MAX <- unique(unlist(MAX_raw)) #length(MAX) = 35911, hence we work with n = 64800-35911 = 28889 cells.

