# Script details ----------------------------------------------------------
# Purpose: Process rotated shapefiles (grid)
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(raster)
xy <- shapefile("./data/meshgrid/meshgrid.shp")
# Processing --------------------------------------------------------------
# Read the data and extract the palaeocoordinates model per model
models <- c("Scotese2",  # PALEOMAP latest version
            "Matthews",  
            "Wright",
            "Seton")
# Define maximum temporal range of models
MaxTime <- c("Scotese2" = 540,
             "Matthews" = 410,
             "Wright" = 540,
             "Seton" = 200)
     
# Directory of output shapefiles            
dir0 <- "C:/Users/lucas/OneDrive/Bureau/Internship_2022/project"

# Extraction loop
for (mdl in models) {
  # Extract coordinates from shapefile
  # we'll store the reconstruction of the coordinates over time here
  coords_over_time <- data.frame(lon_init = xy$lng,   
                                 lat_init = xy$lat)  
  # Update row names
  rownames(coords_over_time) <- 1:nrow(coords_over_time)
  # Extract max time
  maxTime <- MaxTime[[mdl]]
  # Generate time steps
  Timeframe <- seq(from = 10, to = maxTime, by = 10)   
  
  # Create the name of the output datasets' columns
  names <- c("lon_0", "lat_0")
  
  for(t in Timeframe){
    # Reporting for loop progress
    print(t)
    # Generate df names
    names <- c(names, paste0("lon_", t), paste0("lat_", t))
    # Set up directory 
    dir <- paste0(dir0, 
                  "/rotated_shapefiles_10My_intervals/",
                  mdl, "/meshgrid/reconstructed_",
                  t,
                  ".00Ma.shp")
    # Read shape file
    shape <- shapefile(x = dir)
    # Covnert shapefile to dataframe
    df <- as.data.frame(shape)
    # Set up column indexing
    index <- 2 * t / 10
    # Add two empty columns for populating
    coords_over_time[,c(index+1, index+2)] <- NA
    # Match coordinates 
    L_corr <- apply(X = df[, c("lng", "lat")], MARGIN = c(1), FUN = function(j) {
      which((coords_over_time[, c("lon_init")] == j[1]) & 
              (coords_over_time[, "lat_init"] == j[2]))
      })
    # Add coordinates
    coords_over_time[L_corr, c(index + 1, index + 2)] <- df[, c("coords.x1", "coords.x2")]
  }
  # Add col names
  colnames(coords_over_time) <- names
  # Save data
  path <- "./data/grid_paleocoordinates/"
  saveRDS(object = coords_over_time, 
            file = paste0(path, mdl, ".RDS"))
}

