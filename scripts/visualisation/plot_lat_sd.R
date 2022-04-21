################ This script is to plot the latitude STANDARD DEVIATION between the four models over time ################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


library(raster)


## Function to plot either lat or lon sd between the four models ---------------

df <- readRDS("./data/lat_standard_deviation_4mdls.RDS")
pal <- c('#f7fcb9','#d9f0a3','#addd8e','#78c679','#41ab5d','#238443','#006837','#004529') #set the palette


plot_lat_sd <- function(){
  for(k in seq(from = 3, to = ncol(df), by = 1)){
    true_time <- (k-2)*10
    xyz <- df[, c(1,2,k)] #select the corresponding deviation
    r <- rasterFromXYZ(xyz, 
                       crs = "+proj=moll +lon_0=0 +x_0=0 +y_0=0" )  #write the raster file with the mollweide projection coord sys
  
    if(true_time < 100){  #add a zero in front of true_time in the name of the file so that the program used to compile the plot as a GIF could sort them properely
      png(paste0("./figures/standard_deviation/", compound, "/", 0, true_time, ".png"))
    }
    else{
      png(paste0("./figures/standard_deviation/", compound, "/",true_time, ".png"))
    }
    plot.new()
    par(bg = "grey92")
    plot(p,
         axes = FALSE,
         col = pal,
         main = paste0("Latitudinal Standard Deviation between the models ", "(", true_time ,"Ma)"),
         legend.args = list(text = 'Standard deviation (°)', side = 4, font = 2, line = 2.5, cex = 0.8),
         zlim = c(0,60)
         )  #display the output
    plot(worldline_mol,
         add = TRUE,
         col = adjustcolor("grey30",alpha.f=0.5)) #add background map with a semi-transparent grey colour
    dev.off()
  }
  return()
}



## Execute ---------------------------------------------------------------------

plot_lat_sd()
