############# IMPORT MODELS' POLYGONS AS SHAPEFILES AND PROCEED TO THE GEOREFERENCING ################
source("./R/georeferencing_and_NA_pos.R")



###################################### COMPARISON ################################################
#we scale all models on the same grid-cells (maximise the get_na_pos() function for all models of "models")
#Loop to return the indexes of the NA of the models having the smaller coverage (hence the maximal number of cells with no attribute)
source("./R/cells_to_drop.R")



    ########## LATITUDE STANDARD DEVIATION ###########
source("./R/lat_sd.R")

SD <- assess_sd(mdl_list = models) #model list created in the "cells_to_drop.R" file
SD_df <- data.frame(SD)

#we get the initial coordinates of the spatial data points (will be used after as subtracting two dfs makes them = 0, which is annoying for the rest of the work)
coords_ref <- readRDS('./data/extracted_paleocoordinates/Scotese2.RDS')[,1:2]
SD_df[, 1:2] <- coords_ref
saveRDS(SD_df, "./data/standard_deviation_4mdls.RDS")




    ########## LATITUDE DEVIATION (between outputs 2 by 2) ############
source("./R/lat_dev_2_by_2.R")

i = 1 #while loop to run the functions comparing the outputs of each model 2 by 2 (avoiding to compare twice the same models and also not comparing a model with itself)
models_copy = models
thr = 0.5 #all values under 0.5 degrees will be considered as unsignificant change

while(i <= length(models)){
  mdl1 <- models[[i]]
  for(mdl2 in models_copy){
    if(mdl1 != mdl2){
      difference <- assess_diff(mdl1, mdl2, thr)
      saveRDS(difference, 
                file = paste0("./data/latitude_deviation_2_by_2/", mdl1, '_', mdl2, 'diff.RDS'))
    }
  }
  models_copy = models_copy[-1]  #we get rid of the new first element
  i = i+1
}


