################ This script builds a raster to visualise the discrepancies in plateID among the plots... ################
############### ... and assess the amount of pbdb collections that are in each of the 3 zones we highlight ###############


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Libraries -----------------------------------------------------------------------------------------------------
library(RCurl)
library(raster) #just in case, although may have been loaded before

## File built in the "ID_score.R" script ------------------------------------------------------------------------
store <- readRDS("./data/data_pts_plate_IDs_according_to_the_four_models.RDS")

## Rasterizing ---------------------------------------------------------------------------------------------------
r <- rasterFromXYZ(store[,c(1,2,6)], crs = "+proj=longlat +datum=WGS84")
proj_moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"  #mollweide
p <- projectRaster(r, crs = proj_moll)

## Plotting ------------------------------------------------------------------------------------------------------
png("./figures/PlateID_discrepancies.png") #nb: to save as pdf, set width = 10, heigth = 7, and onefile = FALSE
pdf("./figures/PlateID_discrepancies.pdf", width = 10, height = 7, onefile = F)
plot.new()
par(bg = 'grey92')
plot(p, col = c("#fee0d2", "#fc9272", "#ef3b2c"),  
     axes = FALSE,
     legend.args = list(text = 'ID_score', side = 4, font = 2, line = 2.5, cex = 0.8))
plot(worldline_mol,
     add = TRUE) #backround map designed in "background_map.R"
dev.off()



## Quantifying the amount of Paleodb fossil occurrences located in each zone with different ID_scores -----------

RCurl::curlSetOpt(3000)  # extend the time spent waiting for a large file downloading with the RCurl package

#get pbdb collections for the entire Phanerozoic at the global scale, all taxa confounded
API = paste("https://paleobiodb.org/data1.2/colls/list.csv?interval=Fortunian,Holocene&show=loc")

pbdb_collection <- RCurl::getURL(url = API, ssl.verifypeer = FALSE)
pbdb_collection <- read.csv(textConnection(pbdb_collection))

#we convert these data to spatial data points (xy, only coordinates matter)

ID_score_pdb <- extract(x = r, y = pbdb_collection[,4:5]) #r instead of p for projection reasons

prop1 <- length(which(ID_score_pdb == 1))/length(ID_score_pdb) # ~0.56
print(paste0(round(prop1, digit = 1)*100, "% of Paleobiodb collections are in a low discrepancy zone"))

prop2 <- length(which(ID_score_pdb == 2))/length(ID_score_pdb) # ~0.29
print(paste0(round(prop2, digit = 1)*100, "% of Paleobiodb collections are in a mid discrepancy zone"))

prop3 <- length(which(ID_score_pdb == 3))/length(ID_score_pdb) # ~0.08
print(paste0(round(prop, digit = 1)*100, "% of Paleobiodb collections are in a high discrepancy zone"))

propNA <- length(which(is.na(ID_score_pdb) == T))/length(ID_score_pdb) # <0.1, the fossils not in cells covered by our analysis