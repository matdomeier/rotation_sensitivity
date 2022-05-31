library(dggridR)
library(sp)
library(maps)
library(stars)
library(sf)


models <- c("Scotese2",
            "Matthews",  
            "Wright",
            "Seton")

  
## Global initial grid ---------------------------------------------------------
init_grid <- dgconstruct(spacing = 150)

## Palette ---------------------------------------------------------------------
pal <- c('#ffeda0','#fed976','#feb24c','#fd8d3c','#fc4e2a','#e31a1c','#bd0026','#800026')

models_copy = models #defined in "cells_to_drop.R"
i = 1

while(i <= length(models)){
  mdl1 <- models[[i]]
  for(mdl2 in models_copy){
    if(mdl1 != mdl2){
      ## lat_D df --------------------------------------------------------------
      lat_D <- readRDS(paste0("./data/latitude_deviation_2_by_2/", mdl1, "_", mdl2, "diff.RDS"))
      
      ## Overlay cells of lat_D df with cells of the initial grid --------------
      #(lat_0 and lon_0, the two first columns of lat_D, are the coordinates on the present-day map of the rotated centroids of each cell of the grid)
      lat_D$seqnum <- dgGEO_to_SEQNUM(dggs = init_grid, in_lon_deg = lat_D$lon_0, in_lat_deg = lat_D$lat_0)$seqnum
      
      ## Build a grid with cells only containing a lat_D value -----------------
      grid <- dgcellstogrid(init_grid, lat_D$seqnum)
      
      
      for(t in seq(from = 10, to = (ncol(lat_D)-3)*10, by = 10)){
        col <- paste0("lat_", t) #column name in lat_D dataset
        print(col)
        #merge with the lat sd values of an arbitrary time (e.g. 100Ma)
        grid1 <- merge(grid, lat_D[,c("seqnum", col)], by = c("seqnum"))
        
        #getting rid of the cells that will be weirdly plotted (i.e that have wrapping-around coordinates, hence represented as straight east-west lines along the plot)
        getout <- c()
        for(index in 1:length(grid1$geometry)){
          poly <- data.frame(grid1$geometry[[index]][1]) #dataframe containing the coordinates of the index-th polygon
          if( abs(max(poly[,1]) - min(poly[,1])) > 300 ){ 
            getout <- c(getout, index)
          }
        }
        
        grid1$seqnum[getout] = NA
        grid1[getout, col] = NA
        grid1$geometry[getout] = NA
        
        if(t < 100){  #add a zero in front of tin the name of the file so that the program used to compile the plot as a GIF could sort them properely
          png(paste0("./figures/deviation_2_by_2/", mdl1, "_vs_", mdl2, "/", 0, t, ".png"), height = 230, width = 400, units = "mm", res = 200)
        }
        else{
          png(paste0("./figures/deviation_2_by_2/", mdl1, "_vs_", mdl2, "/", t, ".png"), height = 230, width = 400, units = "mm", res = 200)
        }
        
        raster::plot(grid1[col], 
                     pal = pal, 
                     breaks = seq(from = 0, to = 60, by = 7.5),
                     main = paste0("Latitudinal Deviation between the ", mdl1, " and ", mdl2,"models (", t, " Ma)"),
                     cex.main = 1.5)
        
        dev.off()
      }
      
      
          }
  }
  models_copy = models_copy[-1]  #we get rid of the new first element
  i = i+1
}
