library(dggridR)
library(sp)
library(maps)
library(stars)
library(sf)

## Global initial grid ---------------------------------------------------------
init_grid <- dgconstruct(spacing = 150)

## Lat_sd df -------------------------------------------------------------------
lat_sd <- readRDS("./data/lat_standard_deviation_4mdls.RDS")

## Palette ---------------------------------------------------------------------
pal <- c('#f7fcb9','#d9f0a3','#addd8e','#78c679','#41ab5d','#238443','#006837','#004529')

## Overlay cells of lat_sd df with cells of the initial grid -------------------
  #(lat_0 and lon_0, the two first columns of lat_sd, are the coordinates on the present-day map of the rotated centroids of each cell of the grid)
lat_sd$seqnum <- dgGEO_to_SEQNUM(dggs = init_grid, in_lon_deg = lat_sd$lon_0, in_lat_deg = lat_sd$lat_0)$seqnum

## Build a grid with cells only containing a lat_sd value ----------------------
grid <- dgcellstogrid(init_grid, lat_sd$seqnum)

## Loop to plot lat_sd over time out of this grid ------------------------------
for(t in seq(from = 10, to = 540, by = 10)){
  col <- paste0("lat_", t) #column name in lat_sd dataset
  
  #merge with the lat sd values of an arbitrary time (e.g. 100Ma)
  grid1 <- merge(grid, lat_sd[,c("seqnum", col)], by = c("seqnum"))
  
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
    jpeg(paste0("./figures/standard_deviation/", 0, t, ".png"), height = 230, width = 400, units = "mm", res = 800)
  }
  else{
    jpeg(paste0("./figures/standard_deviation/", t, ".png"), height = 230, width = 400, units = "mm", res = 800)
  }
  
  raster::plot(grid1[col], 
               pal = pal, 
               breaks = seq(from = 0, to = 60, by = 7.5),
               main = paste0("Latitudinal Standard Deviation between the models (", t, " Ma)"),
               cex.main = 1.5)
  
  dev.off()
}











t = 200
col <- paste0("lat_", t) #column name in lat_sd dataset

#merge with the lat sd values of an arbitrary time (e.g. 100Ma)
grid1 <- merge(grid, lat_sd[,c("seqnum", col)], by = c("seqnum"))

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

jpeg(filename = "C:/Users/lucas/OneDrive/Bureau/try.jpg", height = 230, width = 400, units = "mm", res = 800)
raster::plot(grid1[col], 
     pal = pal, 
     breaks = seq(from = 0, to = 60, by = 7.5),
     main = paste0("Latitudinal Standard Deviation between the models (", t, " Ma)"),
     cex.main = 1.5)
dev.off()
