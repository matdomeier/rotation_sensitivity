# ------------------------------------------------------------------------- #
# Purpose: Run visualisation scripts
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Simulation component ----------------------------------------------------
## Latitudinal standard deviation time series -----------------------------
# Complete time series and GIF
source("./scripts/visualisation/01a_lat_sd.R")
# Time frame shots
source("./scripts/visualisation/01b_lat_sd_facet.R")

## MST length assessment --------------------------------------------------
# Complete time series and GIF
source("./scripts/visualisation/02a_MST.R")
# Time frame shots
source("./scripts/visualisation/02b_MST_facet.R")

## Cell proportions -------------------------------------------------------
# Cell proportions (lat SD and MST)
source("./scripts/visualisation/03_bar_plots.R")

# Case study component ----------------------------------------------------
## Palaeolatitudinal range plot of occurrences ----------------------------
source("./scripts/visualisation/04_fossil_palaeolat.R") 
## Max absolute palaeolatitudinal limit of occurrences --------------------
source("./scripts/visualisation/05_fossil_tropics.R") 

