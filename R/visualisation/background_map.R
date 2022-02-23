################ This script is to generate the background map using Rnaturalearth ################

## Libraries -----------------------------------------------------------------------------------------------------------
library(rnaturalearth) #INSTALL rnaturalearth, PLEASE FOLLOW THIS LINK => https://cran.r-project.org/web/packages/rnaturalearth/README.html
library(sf)

## Load the worldmaps (countries and coastlines) and project them using the Mollewide projection ------------------------
  
  #coastlines
worldline <- ne_coastline(scale = 50)
worldline_mol <- spTransform(x = worldline,
                             CRSobj = "+proj=moll +lon_0=0 +x_0=0 +y_0=0")

  #countries
worldmap <- ne_countries()
worldmap <- st_as_sf(worldmap)
worldmap_mol <- st_transform(x = worldmap,
                             crs = "+proj=moll +lon_0=0 +x_0=0 +y_0=0")

