################## This function evaluates the latitudinal standard deviation between the outputs of the 4 models ###################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Library ------------------------------------------------------------------------------------------------------------

library(abind)


## List of the maximal time coverage for each of the four models ------------------------------------------------------

MaxTime <- c("Scotese2" = 540,
             "Matthews" = 410,
             "Wright" = 540, #rounded to 540 (instead of 544) for Wright
             "Seton" = 200)  #the maximum time we want to reach, we basically go as far as the model goes

## Big sd function ----------------------------------------------------------------------------------------------------
assess_sd <- function(){
  df1 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", models[[1]], '.RDS')) #models list created in the "build_grid.R" file
  df2 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", models[[2]], '.RDS'))
  df3 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", models[[3]], '.RDS'))
  df4 <- readRDS(file = paste0("./data/extracted_paleocoordinates/", models[[4]], '.RDS'))

  #temporal scaling: we create 3 three-dimensional combinations of arrays for different time slices so we don't end up assessing sd with NAs (that returns a NA)
    #we combine the 2-dimensional arrays in one 3D array (along = 3) for which we'll assess sd
    #note that we only select even indexes as they correspond to lat (the dfs also account for lon)
    comb_array4 <- abind(df1[, seq(from = 4, to = 42, by = 2)], df2[, seq(from = 4, to = 42, by = 2)], df3[, seq(from = 4, to = 42, by = 2)], df4[, seq(from = 4, to = 42, by = 2)], along = 3) #from 10 to 200Ma (4models)
    comb_array3 <- abind(df1[, seq(from = 44, to = 84, by = 2)], df2[, seq(from = 44, to = 84, by = 2)], df3[, seq(from = 44, to = 84, by = 2)], along = 3) #from 210 to 410 (3 models: all except Seton)
    comb_array2 <- abind(df1[, seq(from = 86, to = 110, by = 2)], df3[, seq(from = 86, to = 110, by = 2)], along = 3) #from 420 to 540 (2 models: Scotese and Wright, Matthews eliminated)
    
    
    #Standard deviation assessment on the 3 arrays
    
    SD4 <- apply(comb_array4, 
                 MARGIN = c(1,2), #on the 2 dimensions of the resulting array 
                 FUN = sd) #we apply the sd function
    
    SD3 <- apply(comb_array3, 
                 MARGIN = c(1,2), 
                 FUN = sd)
    
    SD2 <- apply(comb_array2, 
                 MARGIN = c(1,2),
                 FUN = sd)

  #Arrays finally re-assembled
  
  SD <- cbind(SD4, SD3, SD2)
  SD_df <- data.frame(SD)
  
  return(SD_df)
}


## Execute -------------------------------------------------------------------------------------------------
coords_ref <- readRDS('./data/extracted_paleocoordinates/Scotese2.RDS')[,1:2] #we get the initial coordinates of the spatial data points (as subtracting two dfs makes them = 0, which is annoying)
final <- cbind(coords_ref, assess_sd()) #we bound the ref coordinates of each cell to the lat sd assessment
saveRDS(final, file = "./data/lat_standard_deviation_4mdls.RDS")
