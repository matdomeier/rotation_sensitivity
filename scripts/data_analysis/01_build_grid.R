# Script details ----------------------------------------------------------
# Purpose: Build an equal-area icosahedral grid
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(dggridR)
library(rgeos)
library(raster)
library(sp)
# Generate grid -----------------------------------------------------------
# 150km of spacing between each grid's centroids
grid <- dggridR::dgconstruct(spacing = 150) 
# Link discrete grid with earth grid and save as .shp
dggridR::dgearthgrid(dggs = grid,
            savegrid = "./data/meshgrid/icosahedral_grid.shp")
# Extract centroids of grid -----------------------------------------------
cells <- 1:dggridR::dgmaxcell(dggs = grid)
cellcenters <- dggridR::dgSEQNUM_to_GEO(dggs = grid, in_seqnum = cells)
xy <- data.frame(lng = cellcenters$lon_deg, lat = cellcenters$lat_deg)

# Add age range for points (GPlates requirement) --------------------------
xy$Beginning <- 540
xy$End <- 0
# Add CRS -----------------------------------------------------------------
xy <- sp::SpatialPointsDataFrame(coords = xy[, c("lng", "lat")],
                                 data = xy)
proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")
# Remove spatial points not present in all models -------------------------
# Define available models
models <- c("Scotese2", "Matthews", "Wright", "Seton")
# Set up vector to populate
index_to_drop <- vector(mode = "numeric")
# Run for loop across models
for (mdl in models) {
  # Get model shp path
  path <- paste0("./data/continental_polygons/",
                 mdl, "/",
                 mdl, "_PresentDay_ContinentalPolygons.shp")
  # Load model shp
  cont_pol <- raster::shapefile(x = path)
  # Overlap xy with continental polygons and extract plate ID
  georef <- sp::over(x = xy,
                     y = cont_pol)$PLATEID1 
  # Points with NA as plate ID do not have a plate polygon to intersect with
  index_to_drop <- append(index_to_drop, which(is.na(georef)))
}
# Retain unique instances
index_to_drop <- unique(index_to_drop)
# Drop area not present in all models
xy <- xy[-index_to_drop, ]
# Save xy as .shp for GPlates ---------------------------------------------
raster::shapefile(xy, "./data/meshgrid/meshgrid.shp", overwrite = TRUE)  
