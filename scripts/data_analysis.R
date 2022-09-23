# ------------------------------------------------------------------------- #
# Purpose: Run main data analysis
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Simulation component ----------------------------------------------------
## Build the equal-area grid to rotate ------------------------------------
source("./scripts/data_analysis/01_build_grid.R")
rm(list = ls())

# Rotations are then carried out in the GPlates desktop software
# Processing of rotation files provided in the script below
# Raw outputs are not provided here as they are too large for the repository
# These outputs are avaialble upon request, however the processed files 
# are available via ./data/extracted_coordinates
# source("./scripts/data_analysis/02_process_rotations.R")

## Comparison  ------------------------------------------------------------
# Latitudinal standard deviations
source("./scripts/data_analysis/03_lat_sd.R") 
rm(list = ls())

# Calculate minimum spanning tree between points
source("./scripts/data_analysis/04_MST.R")
rm(list = ls())

# Case study --------------------------------------------------------------
## Data pre-processing ----------------------------------------------------
# Clean coral data
source("./scripts/data_analysis/05_prepare_fossil_reef_data.R")
rm(list = ls())

# Clean croc data
source("./scripts/data_analysis/06_prepare_fossil_croc_data.R")
rm(list = ls())

## Rotate fossil occurrences ----------------------------------------------
# Rotate fossil occurrences with GPlates API (via chronosphere) 
source("./scripts/data_analysis/rotate_fossils_with_chronosphere.R")
