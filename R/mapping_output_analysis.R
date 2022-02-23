library(raster)
library(sp)
library(RColorBrewer)
library(rgdal)
library(maps)
library(RCurl)
library(rnaturalearth)
library(sf)

setwd("C:/Users/lucas/OneDrive/Bureau/Internship_2022/project/comparison")

models <- c("Scotese2",
            "Matthews",  
            "Golonka",
            "Seton")


#set background map using rnaturalearth
      #coastlines
worldline <- ne_coastline(scale = 50)
worldline_mol <- spTransform(x = worldline,
                             CRSobj = "+proj=moll +lon_0=0 +x_0=0 +y_0=0")

      #countries
worldmap <- ne_countries()
worldmap <- st_as_sf(worldmap)
worldmap_mol <- st_transform(x = worldmap,
                             crs = "+proj=moll +lon_0=0 +x_0=0 +y_0=0")


####################################### LATITUDE DEVIATION ####################################################



#nb: you need to create the folders "mdl1_vs_mdl2" for all mdls in models



#set the color palette
pal <- c('#ffeda0','#fed976','#feb24c','#fd8d3c','#fc4e2a','#e31a1c','#bd0026','#800026') #sequential

plot_lat_difference <- function(mdl1, mdl2){  
  #function to produce a timeseries of plots showing the deviation in the reconstructed temporal latitudes of the spatial data points according to the two models (mdl1 and mdl2)
  #be careful with the order, otherwise, the file won't be recognized
  
  filename <- paste0(mdl1, '_', mdl2, 'diff.csv')
  df <- read.csv(filename)[,-c(1)]
  
  for(k in seq(from = 4, to = ncol(df), by = 2)){ #we start with the latitude of the -10My point (4th column)
    true_time <- (k-2)*5 #for the plot title ( = ((k-2)/2)*10 )
    xyz <- df[, c(1,2,k)] #select the corresponding latitude deviation
    r <- rasterFromXYZ(xyz, 
                       crs = "+proj=longlat +datum=WGS84")  #write the raster file with the UTM projection coord sys
    
    proj_moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"  #mollweide projection
    p <- projectRaster(r, crs = proj_moll)
    
    if(true_time < 100){  #add a zero in front of true_time in the name of the file so that the program used to compile the plot as a GIF could sort them properely
      png(paste0("./visualisation/", mdl1,"_vs_", mdl2, "/", mdl1,"_v.s_", mdl2, '_', 0, true_time, ".png"))
    }
    else{
      png(paste0("./visualisation/", mdl1,"_vs_", mdl2, "/", mdl1,"_v.s_", mdl2, '_', true_time, ".png"))
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
         main = paste0("Latitude discrepancies hotspots between ", mdl1, " and ", mdl2, " (", true_time ,"Ma)"),
         legend.args = list(text = 'Latitude deviation (°)', side = 4, font = 2, line = 2.5, cex = 0.8),
         zlim = c(0, 60))  #display the output
    plot(worldline_mol,
         add = TRUE)  #add background map
    dev.off()
  }
  return()
}




#computing it for all the models

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




################################ LATITUDE STANDARD DEVIATION BETWEEN THE FOUR MODELS ########################################


pal <- c('#f7fcb9','#d9f0a3','#addd8e','#78c679','#41ab5d','#238443','#006837','#004529')

filename <- paste0('standard_deviation_4mdls.csv')
df <- read.csv(filename)[,-c(1)]

for(k in seq(from = 4, to = ncol(df), by = 2)){ #we start with the latitude of the -10My point (4th column)
  true_time <- (k-2)*5 #for the plot title ( = ((k-2)/2)*10 )
  xyz <- df[, c(1,2,k)] #select the corresponding latitude deviation
  r <- rasterFromXYZ(xyz, 
                     crs = "+proj=longlat +datum=WGS84")  #write the raster file with the UTM projection coord sys
  
  proj_moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"  #mollweide projection
  p <- projectRaster(r, crs = proj_moll)
  
  if(true_time < 100){  #add a zero in front of true_time in the name of the file so that the program used to compile the plot as a GIF could sort them properely
    png(paste0("./visualisation/standard_deviation/", 0, true_time, ".png"))
  }
  else{
    png(paste0("./visualisation/standard_deviation/", true_time, ".png"))
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
       main = paste0("Latitude Standard Deviation between the 4 models ", "(", true_time ,"Ma)"),
       legend.args = list(text = 'Standard deviation (°)', side = 4, font = 2, line = 2.5, cex = 0.8),
       zlim = c(0, 40))  #display the output
  plot(worldline_mol,
       add = TRUE,
       col = adjustcolor("grey30",alpha.f=0.5)) #add background map with a semi-transparent grey colour
  dev.off()
}







k = 42


true_time <- (k-2)*5 #for the plot title ( = ((k-2)/2)*10 )
xyz <- df[, c(1,2,k)] #select the corresponding latitude deviation
r <- rasterFromXYZ(xyz, 
                   crs = "+proj=longlat +datum=WGS84")  #write the raster file with the UTM projection coord sys

proj_moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"  #mollweide projection
p <- projectRaster(r, crs = proj_moll)

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
     main = paste0("Latitude Standard Deviation between the 4 models ", "(", true_time ,"Ma)"),
     legend.args = list(text = 'Standard deviation (°)', side = 4, font = 2, line = 2.5, cex = 0.8),
     zlim = c(0, 40))  #display the output
plot(worldline_mol,
     add = TRUE,
     col = adjustcolor("grey30",alpha.f=0.5)) #add background map with a semi-transparent grey colour














### FOR THE SCRIPT TO WRITE THE GIFS, SEE THE PYTHON NOTEBOOK "make_GIFs.ipynb"



######################################## PLATEIDs ASSIGNEMENT #################################################

setwd("C:/Users/lucas/OneDrive/Bureau/Internship_2022/project/extracted_paleocoordinates/georeferenced")
store <- read.csv('./Scotese2.csv')[,-c(1,4:8)]

length(unique(na.omit(store$georef))) #number of single plateIDs assigned

without_seton <- models[-c(4)]

i = 1
while(i < length(without_seton)){
  i = i+1
  store[,i+2] <- read.csv(paste0(models[i], '.csv'))$georef
}

colnames(store) <- c("lon_0", "lat_0", "Scotese2_ID", "Matthews_ID", "Golonka_ID")

#Nothing was working, it made me angry, hence I wrote this ugly combination of loops
#The point is to get rid of any line with at list one "NA" in the plate IDs... to be improved by maybe getting rid of the NAs when all non-terrestrial models agree, plate boundaries otherwise...

to_drop <- c()
for(index in 1:nrow(store)){
  for(k in 3:5){
    if(is.na(store[index,k]) == T){
      to_drop <- c(to_drop, index)
    }
  }
}
store <- store[-unique(to_drop),]

source("C:/Users/lucas/OneDrive/Documents/GitHub/internship_2022/scripts/georeferencing_and_NA_pos.R")
source('C:/Users/lucas/OneDrive/Documents/GitHub/internship_2022/scripts/cells_to_drop.R')

store <- store[-MAX,]


    
  # Assess the ID_weight, a metric quantifying the number of different plate IDs a point may have been assigned to

store$ID_weight <- 0

for(id in 1:nrow(store)){
  store$ID_weight[id] <- length(unique(as.numeric(store[id,3:6])))  #the length of the plateID row without duplicates
}

write.csv(store, file = "data_pts_plate_IDs_according_to_the_four_models.csv")


#Building a raster to visualise them

store <- read.csv("data_pts_plate_IDs_according_to_the_four_models.csv")[,-c(1)]

r <- rasterFromXYZ(store[,c(1,2,7)], crs = "+proj=longlat +datum=WGS84")
proj_moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"  #mollweide
p <- projectRaster(r, crs = proj_moll)

#Plotting

par(bg = 'white')
plot(p, col = c('grey', 'yellow', 'red'),  axes = FALSE, add = FALSE)
plot(worldline_mol,
     add = TRUE)


    
    #Quantifying the amount of Paleodb fossil occurrences located in a "risky zone" (zone of discrepancy among the models)

RCurl::curlSetOpt(3000)  # extend the time spent waiting for a large file downloading with the RCurl package

#get pbdb collections for the entire Phanerozoic at the global scale, all taxa confounded
API = paste("https://paleobiodb.org/data1.2/colls/list.csv?interval=Fortunian,Holocene&show=loc")

pbdb_collection <- RCurl::getURL(url = API, ssl.verifypeer = FALSE)
pbdb_collection <- read.csv(textConnection(pbdb_collection))

#we convert these data to spatial data points (xy, only coordinates matter)

ID_weight_pdb <- extract(x = r, y = pbdb_collection[,4:5]) #r instead of p for projection reasons

prop1 <- length(which(ID_weight_pdb == 1))/length(ID_weight_pdb) # ~0.54
prop2 <- length(which(ID_weight_pdb == 2))/length(ID_weight_pdb) # ~0.28
prop3 <- length(which(ID_weight_pdb == 3))/length(ID_weight_pdb) # ~0.08

propNA <- length(which(is.na(ID_weight_pdb) == T))/length(ID_weight_pdb) # ~0.1