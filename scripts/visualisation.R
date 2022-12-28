# ------------------------------------------------------------------------- #
# Purpose: Run visualisation scripts
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Simulation component ----------------------------------------------------
## Latitudinal standard deviation time series -----------------------------
### Complete time series and GIF ------------------------------------------
source("./scripts/visualisation/01a_lat_sd.R")
rm(list = ls())
### Time frame shots ------------------------------------------------------
source("./scripts/visualisation/01b_lat_sd_facet.R")
rm(list = ls())

## MST length assessment --------------------------------------------------
### Complete time series and GIF ------------------------------------------
source("./scripts/visualisation/02a_MST.R")
rm(list = ls())
### Time frame shots ------------------------------------------------------
source("./scripts/visualisation/02b_MST_facet.R")
rm(list = ls())

## Cell proportions -------------------------------------------------------
source("./scripts/visualisation/03_bar_plots.R")
rm(list = ls())

# Case study component ----------------------------------------------------
## Palaeolatitudinal range plot of occurrences ----------------------------
source("./scripts/visualisation/04_fossil_palaeolat.R") 
rm(list = ls())

## Max absolute palaeolatitudinal limit of occurrences --------------------
source("./scripts/visualisation/05_fossil_tropics.R") 
rm(list = ls())

# Miscellaneous -----------------------------------------------------------
# Generate polygon maps
source("./scripts/visualisation/06_polygon_maps.R") 
rm(list = ls())

# Generate Cambrian polygon maps
source("./scripts/visualisation/07_cambrian_polygon_maps.R") 
rm(list = ls())

# Generate models phylogeny
source("./scripts/visualisation/08_models_phylogeny.R") 
rm(list = ls())

