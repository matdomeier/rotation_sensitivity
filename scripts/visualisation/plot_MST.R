################ This script plots as time series maps the MST length assessment ###################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com

library(raster)

pal <- c('#fde0dd','#fcc5c0','#fa9fb5','#f768a1','#dd3497','#ae017e','#7a0177','#49006a')


df <- readRDS("./data/MST_length.RDS")

for(k in seq(from = 3, to = ncol(df), by = 1)){ #we start with the latitude of the -10My point (4th column)
  true_time <- (k-2)*10 #for the plot title
  xyz <- df[, c(1,2,k)] #select the corresponding latitude deviation
  r <- rasterFromXYZ(xyz, 
                     crs = "+proj=longlat +datum=WGS84")  #write the raster file with the UTM projection coord sys
  
  proj_moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"  #mollweide projection
  p <- projectRaster(r, crs = proj_moll)
  
  if(true_time < 100){  #add a zero in front of true_time in the name of the file so that the program used to compile the plot as a GIF could sort them properely
    png(paste0("./figures/MST/", 0, true_time, ".png"))
  }
  else{
    png(paste0("./figures/MST/", true_time, ".png"))
  }
  plot.new()
  # 
  # rect(par("usr")[1], par("usr")[3],
  #      par("usr")[2], par("usr")[4],
  #      col = "grey92") #set light grey background
  # par(new = TRUE)
  par(bg = "grey92")
  plot(p,
       axes = FALSE,
       col = pal,
       main = paste0("MST length between the 4 models ", "(", true_time ,"Ma)"),
       legend.args = list(text = 'MST length (x10^3 km)', side = 4, font = 2, line = 2.5, cex = 0.8),
       zlim = c(0,17))  #display the output
  plot(worldline_mol,
       add = TRUE,
       col = adjustcolor("grey30",alpha.f=0.5)) #add background map with a semi-transparent grey colour
  dev.off()
}
