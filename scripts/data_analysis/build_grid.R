################ This script builds an equal-area icosahedral grid, the area of which correspond to a 1°x1° pixel at the equator ##################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


library(dggridR)
library(rgeos)
library(raster)
library(sp)

## build a discrete global icosahedral grid (dgg) ------------------------------
grid <- dgconstruct(spacing = 150) #150km of spacing between each grid's centroids, which is ~ 1° at  the equator (111), and corresponds to a resolution of 7

##link it with the earth and export it as a .shp -------------------------------
dgearthgrid(dggs = grid,
            savegrid = "./data/meshgrid/icosahedral_grid.shp")

## open the exported shapefile -------------------------------------------------
grid_shp <- shapefile("./data/meshgrid/icosahedral_grid.shp")

## get centroids of each cells as spatial data point ---------------------------
spdp <- rgeos::gCentroid(grid_shp, byid = TRUE)
xy.df <- data.frame(spdp) #dataframe of the coordinates of the centroids
xy.df$Beginning <- 540
xy.df$End <- 0
xy.df <- SpatialPointsDataFrame(coords = xy.df[,1:2], data = xy.df)
proj4string(xy.df)<- CRS("+proj=longlat +datum=WGS84") #assign coord system to the SpatialPointsDataFrame

## Eliminate points not covered by at least one model --------------------------

models <- c("Scotese2", "Matthews", "Wright", "Seton")
index_to_drop <- c()
for(mdl in models){
  path <- paste0("./data/continental_polygons/", mdl, "/", mdl, "_PresentDay_ContinentalPolygons.shp")
  cont_pol <- shapefile(path) #we open the present-day continental polygons corresponding to the model
  georef <- sp::over(xy.df, cont_pol)$PLATEID1 #we overlay our spatial xy.df with the continental polygons by plate ID
  index_to_drop <- c(index_to_drop, which(is.na(georef) == TRUE)) #we target the points not associated with any plate ID (that will therefore not be rotated)
}
index_to_drop <- unique(index_to_drop) #eliminate redundancy
xy.df <- xy.df[-index_to_drop, ] #finally get rid of them

## export the spatial points dataframe as a shapefile --------------------------
raster::shapefile(xy.df, "./data/meshgrid/meshgrid.shp", overwrite = TRUE)  #create shapefile from the SpatialPtsDF and save it with the same command
