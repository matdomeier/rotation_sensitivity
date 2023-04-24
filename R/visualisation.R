# ------------------------------------------------------------------------- #
# Purpose: Run visualisation scripts
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Simulation component ----------------------------------------------------
## Latitudinal standard deviation time series -----------------------------
### Complete time series and GIF ------------------------------------------
source("./R/visualisation/01a_lat_sd.R")
rm(list = ls())
### Time frame shots ------------------------------------------------------
source("./R/visualisation/01b_lat_sd_facet.R")
rm(list = ls())

## Normalised geodesic distance assessment --------------------------------
### Complete time series and GIF ------------------------------------------
source("./R/visualisation/02a_geodes_dist.R")
rm(list = ls())
### Time frame shots ------------------------------------------------------
source("./R/visualisation/02b_geodes_dist_facet.R")
rm(list = ls())

## Cell proportions -------------------------------------------------------
source("./R/visualisation/03_bar_plots.R")
rm(list = ls())

# Case study component ----------------------------------------------------
## Palaeolatitudinal range plot of occurrences ----------------------------
source("./R/visualisation/04_fossil_palaeolat.R") 
rm(list = ls())

## Max absolute palaeolatitudinal limit of occurrences --------------------
source("./R/visualisation/05_fossil_tropics.R") 
rm(list = ls())

# Miscellaneous -----------------------------------------------------------
# Generate polygon maps
source("./R/visualisation/06_polygon_maps.R") 
rm(list = ls())

# Generate Cambrian polygon maps
source("./R/visualisation/07_cambrian_polygon_maps.R") 
rm(list = ls())

# Generate models phylogeny
source("./R/visualisation/08_models_phylogeny.R") 
rm(list = ls())

