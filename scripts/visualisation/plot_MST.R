################ This script plots as time series maps the MST length assessment ###################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


library(dggridR)
library(sp)


## Global initial grid ---------------------------------------------------------
init_grid <- dgconstruct(spacing = 150)


## mst_length df -------------------------------------------------------------------
mst_length <- readRDS("./data/MST_length.RDS")


## Palette ---------------------------------------------------------------------
pal <- c('#fde0dd','#fcc5c0','#fa9fb5','#f768a1','#dd3497','#ae017e','#7a0177','#49006a')

## Overlay cells of mst_length df with cells of the initial grid -------------------
#(lat_0 and lon_0, the two first columns of mst_length, are the coordinates on the present-day map of the rotated centroids of each cell of the grid)
mst_length$seqnum <- dgGEO_to_SEQNUM(dggs = init_grid, in_lon_deg = mst_length$lon_0, in_lat_deg = mst_length$lat_0)$seqnum


## Build a grid with cells only containing a mst_length value ----------------------
grid <- dgcellstogrid(init_grid, mst_length$seqnum)


## Loop to plot mst_length over time out of this grid ------------------------------
for(t in seq(from = 10, to = 540, by = 10)){
  col <- paste0("MST_length_", t) #column name in mst_length dataset
  
  #merge with the lat sd values at t
  grid1 <- merge(grid, mst_length[,c("seqnum", col)], by = c("seqnum"))
  
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
    png(paste0("./figures/MST/", 0, t, ".png"), height = 230, width = 400, units = "mm", res = 200)
  }
  else{
    png(paste0("./figures/MST/", t, ".png"), height = 230, width = 400, units = "mm", res = 200)
  }
  
  raster::plot(grid1[col], 
               pal = pal, 
               breaks = seq(from = 0, to = 12, by = 1.5),
               main = paste0("MST length between the models (", t, " Ma)"),
               cex.main = 1.5)
  
  dev.off()
}
