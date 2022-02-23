
######################################################## DATA ANALYSIS ########################################################


## Import model's polygons as shapefiles and proceed to the georeferencing ----------------------------
source("./scripts/data_analysis/georeferencing_and_NA_pos.R")



## COMPARISON ------------------------------------------------------------------------------------------
#we scale all models on the same grid-cells (maximise the get_na_pos() function for all models of "models")
#Loop to return the indexes of the NA of the models having the smaller coverage (hence the maximal number of cells with no attribute)
source("./scripts/data_analysis/cells_to_drop.R")



## Latitude standard deviation -------------------------------------------------------------------------
source("./scripts/data_analysis/lat_sd.R")



## Plate ID assignment discrepancies --------------------------------------------------------------------
source("./scripts/data_analysis/ID_weight.R") #generates the dataframe containing the ID_weights for all our cells


## Latitude deviation (between outputs 2 by 2) ----------------------------------------------------------
source("./scripts/data_analysis/lat_dev_2_by_2.R")
