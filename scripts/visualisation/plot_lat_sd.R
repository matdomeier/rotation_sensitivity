################ This script is to plot the latitude STANDARD DEVIATION between the four models over time ################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


library(raster)


## Function to plot either lat or lon sd between the four models ---------------

df <- readRDS("./data/standard_deviation_4mdls.RDS")

plot_sd <- function(compound){ #compound = "Latitude" or "Longitude"
  if(compound == "Latitude"){
    start_index = 4 #we start with the value of the 10Ma point (4th column for lat, 3rd for lon)
    stop_index = ncol(df)
    reeq_coeff = 2
    pal <- c('#f7fcb9','#d9f0a3','#addd8e','#78c679','#41ab5d','#238443','#006837','#004529') #set the palette
    zlim <- c(0,60)
  }
  else if(compound == "Longitude"){
    start_index = 3
    stop_index = ncol(df)-1
    reeq_coeff = 1
    pal <- c('#edf8b1','#c7e9b4','#7fcdbb','#41b6c4','#1d91c0','#225ea8','#253494','#081d58')
    zlim <- NA
  }
  
  for(k in seq(from = start_index, to = stop_index, by = 2)){
    true_time <- (k-reeq_coeff)*5 #for the plot title ( = ((k-2)/2)*10 for lat and ((k-1)/2)*10 for lon)
    xyz <- df[, c(1,2,k)] #select the corresponding deviation
    r <- rasterFromXYZ(xyz, 
                       crs = "+proj=longlat +datum=WGS84")  #write the raster file with the UTM projection coord sys
    
    proj_moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"  #mollweide projection
    p <- projectRaster(r, crs = proj_moll)
    
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
         main = paste0(compound," Standard Deviation between the models ", "(", true_time ,"Ma)"),
         legend.args = list(text = 'Standard deviation', side = 4, font = 2, line = 2.5, cex = 0.8),
         #zlim = zlim
         )  #display the output
    plot(worldline_mol,
         add = TRUE,
         col = adjustcolor("grey30",alpha.f=0.5)) #add background map with a semi-transparent grey colour
    dev.off()
  }
  return()
}



## Execute ---------------------------------------------------------------------

for(compound in c("Latitude", "Longitude")){
  plot_sd(compound)
}
