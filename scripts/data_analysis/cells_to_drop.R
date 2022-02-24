############ THIS SCRIPT ASSESSES THE INDEXES OF THE CELLS TO DROP FOR THE SPATIAL SCALING ###################

## Loading libraries -----------------------------------------------------------------------------------------
library(sp)
library(abind)


## List of model's names -------------------------------------------------------------------------------------
models <- c("Scotese2",  #PALEOMAP latest version
            "Matthews",  
            "Golonka",
            "Seton")


## Computing the List of the indexes to drop to spatially scale the outputs ----------------------------------

i = 1
MAX <- get_na_pos(models[i]) # function in "georeferencing_and_NA_pos.R" script
while(i<4){
  i = i+1
  test <- get_na_pos(models[i])
  if(length(test) > length(MAX)){
    MAX <- test
    print(models[i]) #GOLONKA IS THE MODEL WITH THE SMALLER NUMBER OF CELLS WITH VALUES
  }
}

MAX <- unique(MAX)

#we look for potential remaining NAs in the other models after removing all cells not covered by Golonka


to_add <- c() #list that will contain the indexes to add, ie remaining NAs in the Matthew and Scotese datasets after cleaning golonka's NAs position 
for(mdl in c("Scotese2", "Matthews")){
  georef <- readRDS(paste0("./data/georeferenced/", mdl,".RDS"))
  to_add <- c(to_add, which(is.na(georef$georef[-MAX]) == TRUE)) #we add the remaining NAs after cleaning up Golonka's ones
}

MAX <- c(MAX, unique(to_add)) #these NAs are added and we use unique() to avoid adding twice the same indexes
#length(MAX) = 35300 => we work with 64800-length(MAX) = 29500 cells




