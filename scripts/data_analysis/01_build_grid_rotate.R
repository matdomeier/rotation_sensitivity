# Script details ----------------------------------------------------------
# Purpose: Build an equal-area icosahedral grid and rotate
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(h3jsr)
library(palaeoverse)
library(sf)
library(raster)
library(sp)
# Generate grid -----------------------------------------------------------
# Get cells from resolution at 0
cells <- h3jsr::get_res0()
# Get child cells at resolution ~100 km
cells <- get_children(h3_address = cells, res = 3)
# Unlist cell list
cells <- unlist(cells)
# Get centroids of cells
xy <- cell_to_point(cells, simple = FALSE)
# Extract coordinates
xy <- sf::st_coordinates(xy)
xy <- data.frame(xy)
# Update column names
colnames(xy) <- c("lng", "lat")
# Add CRS -----------------------------------------------------------------
xy <- sp::SpatialPointsDataFrame(coords = xy[, c("lng", "lat")],
                                 data = xy)
proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")
# Remove spatial points not present in all models -------------------------
# Define models
models <- c("MERDITH2021",
            "PALEOMAP",
            "GOLONKA",
            "SETON2012",
            "MULLER2016",
            "MATTHEWS2016_pmag_ref")
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
# Convert to df
xy <- as.data.frame(xy)[, c("lng", "lat")]
plot(xy)
# Rotate points -----------------------------------------------------------
# Define maximum temporal range of models
max_time <- c("MERDITH2021" = 540,
              "PALEOMAP" = 540,
              "GOLONKA" = 540,
              "SETON2012" = 200,
              "MULLER2016" = 230,
              "MATTHEWS2016_pmag_ref" = 410)

# Run for loop across models
for (m in models) {
  print(m)
  # Create tmp df with coords
  tmp <- xy
  # Set up time frame of study per model max age
  time_frame <- seq(from = 10, to = max_time[m], by = 10)  
  # Run across ages
  coords <- lapply(time_frame, function(x) {
    # Add age
    tmp$age <- x
    # Rotate cell centroids
    out <- palaeorotate(occdf = tmp, method = "point", model = m)
    # Format output
    out <- out[, c("p_lng", "p_lat")]
    colnames(out) <- c(paste0("lng_", x), paste0("lat_", x))
    # Return output
    out
  })
  # Bind data
  coords <- do.call(cbind.data.frame, coords)
  # Add reference coords
  coords <- cbind.data.frame(xy, coords)
  # Save data
  saveRDS(object = coords, file = paste0("./data/grid_palaeocoordinates/", m, ".RDS"))
}
