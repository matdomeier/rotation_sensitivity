# ------------------------------------------------------------------------- #
# Purpose: Run main data analysis
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Simulation component ----------------------------------------------------
## Build the equal-area grid to rotate ------------------------------------
source("./scripts/data_analysis/build_grid.R")
rm(list = ls())

# Rotations are then carried out in the GPlates desktop software
# Processing of rotation files provided in the script below
# Raw outputs are not provided here as they are too large for the repository
# These outputs are avaialble upon request, however the processed files 
# are available via ./data/extracted_coordinates
# source("./scripts/data_analysis/process_rotations.R")

## Comparison  ------------------------------------------------------------
# Latitudinal standard deviations
source("./scripts/data_analysis/lat_sd.R") 
rm(list = ls())

# Calculate minimum spanning tree between points
source("./scripts/data_analysis/MST.R")
rm(list = ls())

# Case study --------------------------------------------------------------
## Data pre-processing ----------------------------------------------------
# Clean coral data
source("./scripts/data_analysis/prepare_fossil_reef_data.R")
# Clean croc data
source("./scripts/data_analysis/prepare_fossil_croc_data.R")
# Prepare shapefile for rotation
source("./scripts/data_analysis/create_sfs.R")

# Rotations are then carried out in the GPlates desktop software
# Processing of rotation files provided in the script below
# Raw outputs are not provided here as they are too large for the repository
# These outputs are avaialble upon request, however the processed files 
# are available via ./data/fossil_extracted_coordinates

## Rotate fossil occurrences ----------------------------------------------
# Rotate fossil occurrences with GPlates API (via chronosphere) 
source("./scripts/data_analysis/rotate_fossils_with_chronosphere.R")
