################ This script builds a raster to visualise the discrepancies in plateID among the plots... ################
############### ... and assess the amount of pbdb collections that are in each of the 3 zones we highlight ###############

## Libraries -----------------------------------------------------------------------------------------------------
library(RCurl)
library(raster) #just in case, although may have been loaded before

## File built in the "ID_weight.R" script ------------------------------------------------------------------------
store <- readRDS("./data/data_pts_plate_IDs_according_to_the_four_models.RDS")

## Rasterizing ---------------------------------------------------------------------------------------------------
r <- rasterFromXYZ(store[,c(1,2,6)], crs = "+proj=longlat +datum=WGS84")
proj_moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"  #mollweide
p <- projectRaster(r, crs = proj_moll)

## Plotting ------------------------------------------------------------------------------------------------------
png("./figures/PlateID_discrepancies.png")
plot.new()
par(bg = 'white')
plot(p, col = c('grey', 'yellow', 'red'),  axes = FALSE)
plot(worldline_mol,
     add = TRUE) #backround map designed in "background_map.R"
dev.off()



## Quantifying the amount of Paleodb fossil occurrences located in each zone with different ID_weights -----------

RCurl::curlSetOpt(3000)  # extend the time spent waiting for a large file downloading with the RCurl package

#get pbdb collections for the entire Phanerozoic at the global scale, all taxa confounded
API = paste("https://paleobiodb.org/data1.2/colls/list.csv?interval=Fortunian,Holocene&show=loc")

pbdb_collection <- RCurl::getURL(url = API, ssl.verifypeer = FALSE)
pbdb_collection <- read.csv(textConnection(pbdb_collection))

#we convert these data to spatial data points (xy, only coordinates matter)

ID_weight_pdb <- extract(x = r, y = pbdb_collection[,4:5]) #r instead of p for projection reasons

prop1 <- length(which(ID_weight_pdb == 1))/length(ID_weight_pdb) # ~0.54
print(paste0(prop1*100, "% of Paleobiodb collections are in a grey zone"))

prop2 <- length(which(ID_weight_pdb == 2))/length(ID_weight_pdb) # ~0.28
print(paste0(prop2*100, "% of Paleobiodb collections are in a grey zone"))

prop3 <- length(which(ID_weight_pdb == 3))/length(ID_weight_pdb) # ~0.08
print(paste0(prop3*100, "% of Paleobiodb collections are in a grey zone"))

propNA <- length(which(is.na(ID_weight_pdb) == T))/length(ID_weight_pdb) # ~0.1, the fossils not in cells covered by our analysis