# ------------------------------------------------------------------------- #
# Purpose: Run main data analysis
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Simulation component ----------------------------------------------------
## Build the equal-area grid and rotate -----------------------------------
source("./scripts/data_analysis/01_build_grid_rotate.R")
rm(list = ls())

## Comparison  ------------------------------------------------------------
# Latitudinal standard deviation
source("./scripts/data_analysis/02_lat_sd.R") 
rm(list = ls())

# Calculate minimum spanning tree length between points
source("./scripts/data_analysis/03_MST.R")
rm(list = ls())

# Case study --------------------------------------------------------------
## Data pre-processing ----------------------------------------------------
# Clean coral data
source("./scripts/data_analysis/04_prepare_fossil_reef_data.R")
rm(list = ls())

# Clean croc data
source("./scripts/data_analysis/05_prepare_fossil_croc_data.R")
rm(list = ls())

## Rotate fossil occurrences ----------------------------------------------
# Rotate fossil occurrences with GPlates API (via palaeoverse) 
source("./scripts/data_analysis/06_rotate_fossils.R")
rm(list = ls())