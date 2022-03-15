
############################################### DATA ANALYSIS ########################################################


###### SIMULATION PART ######

## Import model's polygons as shapefiles and proceed to the georeferencing ----------------------------
source("./scripts/data_analysis/georeferencing_and_NA_pos.R") #georeferencing
source("./scripts/data_analysis/cells_to_drop.R") #spatial scaling of the ourputs of the models


## COMPARISON ------------------------------------------------------------------------------------------
source("./scripts/data_analysis/lat_sd.R") # Latitude standard deviation
source("./scripts/data_analysis/lat_dev_2_by_2.R") # Latitude deviation (between outputs 2 by 2)
source("./scripts/data_analysis/MST.R") # MST computation (TAKES A WHILE.. should consider a parallelisation!!)

source("./scripts/data_analysis/ID_score.R") # Plate ID assignment discrepancies


###### CASE STUDY ######

## Data pre-processing --------------------------------------------------------------------------------
source("./scripts/data_analysis/prepare_fossil_reef_data.R") # cleaning corals data
source("./scripts/data_analysis/prepare_fossil_croc_data.R") #cleaning crocs data
source("./scripts/data_analysis/create_sfs.R") #prepare input shapefiles for Gplates

# rotating in Gplates and output shapefiles not provided as too heavy: for each model and each taxon, the coordinates of the rotated occurrences are pooled in one RDS file
# see "./scripts/data_analysis/extract_fossils_palaeocoordinates.R" for that