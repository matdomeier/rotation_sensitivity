
######################################################## DATA ANALYSIS ########################################################


## Import model's polygons as shapefiles and proceed to the georeferencing ----------------------------
source("./scripts/data_analysis/georeferencing_and_NA_pos.R")



## COMPARISON ------------------------------------------------------------------------------------------
source("./scripts/data_analysis/cells_to_drop.R") #spatial scaling of the ourputs of the models

source("./scripts/data_analysis/lat_sd.R") # Latitude standard deviation
source("./scripts/data_analysis/lat_dev_2_by_2.R") # Latitude deviation (between outputs 2 by 2)

source("./scripts/data_analysis/ID_weight.R") # Plate ID assignment discrepancies


