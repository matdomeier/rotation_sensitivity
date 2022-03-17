############ THIS SCRIPT ASSESSES THE INDEXES OF THE CELLS TO DROP FOR THE SPATIAL SCALING ###################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Loading libraries -----------------------------------------------------------------------------------------
library(sp)
library(abind)


## List of model's names -------------------------------------------------------------------------------------
models <- c("Scotese2",  #PALEOMAP latest version
            "Matthews",  
            "Wright",
            "Seton")



#The point here is to scale all models on the same grid-cells (maximise the get_na_pos() function for all models of "models")
#Loop to return the indexes of the NA of the models having the smaller coverage (hence the maximal number of cells with no attribute)




## Computing the List of the indexes to drop to spatially scale the outputs ----------------------------------

i = 1
MAX <- get_na_pos(models[i]) # function in "georeferencing_and_NA_pos.R" script
while(i<4){
  i = i+1
  test <- get_na_pos(models[i])
  if(length(test) > length(MAX)){
    MAX <- test
    print(models[i]) #WRIGHT IS THE MODEL WITH THE SMALLER NUMBER OF CELLS WITH VALUES
  }
}

MAX <- unique(MAX)

#we look for potential remaining NAs in the other models after removing all cells not covered by Wright


to_add <- c() #list that will contain the indexes to add, ie remaining NAs in the Matthew and Scotese datasets after cleaning Wright's NAs position 
for(mdl in c("Scotese2", "Matthews")){
  georef <- readRDS(paste0("./data/georeferenced/", mdl,".RDS"))
  to_add <- c(to_add, which(is.na(georef$georef[-MAX]) == TRUE)) #we add the remaining NAs after cleaning up Wright's ones
}

MAX <- c(MAX, unique(to_add)) #these NAs are added and we use unique() to avoid adding twice the same indexes
#length(MAX) = 43381 => we work with 64800-length(MAX) = 21419 cells




