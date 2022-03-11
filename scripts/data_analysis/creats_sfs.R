############## This function creates a shapefile from the occurences that will further be rotated using Gplates ##############

## Libraries -------------------------------------------------------------------
library(raster)

## Split into as many spatial data points dfs as time bins ---------------------
    # nb: we have 24 time bins for crocs (from 5 to 235 with an increment of 10)
    # and 23 from corals (same as crocs but without 85 and 225 and with a NA)

create_sf <- function(taxon){
  
  df <- readRDS(paste0('./data/occurrences/cleaned_', taxon, '_dataset.RDS'))
  xy <- df[, c("lng", "lat")]

  xy$Beginning <- max(unique(df$bin_mid_ma))
  xy$End <- 0
  xy.df <- SpatialPointsDataFrame(coords = xy[,1:2], data = xy)
  proj4string(xy.df)<- CRS("+proj=longlat +datum=WGS84")
  raster::shapefile(xy.df, paste0('./data/occurrences/', taxon,'_to_rotate.shp'), overwrite=TRUE)
  
}

## Execute ---------------------------------------------------------------------

taxa <- c("Crocos", "Corals")
for(taxon in taxa){
  create_sf(taxon)
}
