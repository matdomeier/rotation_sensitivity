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
source("./scripts/data_analysis/MST.R") # MST computation (TAKES A WHILE!!)
rm(list = ls())

###### CASE STUDY ######

## Data pre-processing --------------------------------------------------------------------------------
source("./scripts/data_analysis/prepare_fossil_reef_data.R") # cleaning corals data
source("./scripts/data_analysis/prepare_fossil_croc_data.R") #cleaning crocs data
source("./scripts/data_analysis/create_sfs.R") #prepare input shapefiles for Gplates

# rotating in Gplates and output shapefiles not provided as too heavy: for each model and each taxon, the coordinates of the rotated occurrences are pooled in one RDS file
# see "./scripts/data_analysis/extract_fossils_palaeocoordinates.R" for that

## Rotating fossil occurrences with Chronosphere package (instead of manually in Gplates) -------------
source("./scripts/data_analysis/rotate_fossils_with_chronosphere.R")
