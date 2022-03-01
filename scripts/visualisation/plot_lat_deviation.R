################ This script is for latitude deviation estimation between the outputs of the models 2 by 2 ################



#nb: you need to create the folders "mdl1_vs_mdl2" for all mdls in models


models <- c("Scotese2",  #PALEOMAP latest version
            "Matthews",  
            "Golonka",
            "Seton")


#set the color palette
pal <- c('#ffeda0','#fed976','#feb24c','#fd8d3c','#fc4e2a','#e31a1c','#bd0026','#800026') #sequential

plot_lat_difference <- function(mdl1, mdl2){  
  #function to produce a timeseries of plots showing the deviation in the reconstructed temporal latitudes of the spatial data points according to the two models (mdl1 and mdl2)
  #be careful with the order of the models you are comparing, otherwise, the file won't be recognized
  
  filename <- paste0("./data/latitude_deviation_2_by_2/", mdl1, '_', mdl2, 'diff.RDS')
  df <- readRDS(filename)
  
  for(k in seq(from = 4, to = ncol(df), by = 2)){ #we start with the latitude of the -10My point (4th column)
    true_time <- (k-2)*5 #for the plot title ( = ((k-2)/2)*10 )
    xyz <- df[, c(1,2,k)] #select the corresponding latitude deviation
    r <- rasterFromXYZ(xyz, 
                       crs = "+proj=longlat +datum=WGS84")  #write the raster file with the UTM projection coord sys
    
    proj_moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"  #mollweide projection
    p <- projectRaster(r, crs = proj_moll)
    
    if(true_time < 100){  #add a zero in front of true_time in the name of the file so that the program used to compile the plot as a GIF could sort them properely
      png(paste0("./figures/", mdl1,"_vs_", mdl2, "/", mdl1,"_v.s_", mdl2, '_', 0, true_time, ".png"))
    }
    else{
      png(paste0("./figures/", mdl1,"_vs_", mdl2, "/", mdl1,"_v.s_", mdl2, '_', true_time, ".png"))
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
         main = paste0("Latitude deviation beteen ", mdl1, " and ", mdl2, " (", true_time ,"Ma)"),
         legend.args = list(text = 'Latitude deviation', side = 4, font = 2, line = 2.5, cex = 0.8),
         zlim = c(0, 60))  #display the output
    plot(worldline_mol,
         add = TRUE)  #add background map
    dev.off()
  }
  return()
}



#computing the function for all the models
i = 1
models_copy = models

while(i <= length(models)){
  mdl1 <- models[[i]]
  for(mdl2 in models_copy){
    if(mdl1 != mdl2){
      plot_lat_difference(mdl1, mdl2)
    }
  }
  models_copy = models_copy[-1]  #we get rid of the new first element
  i = i+1
}