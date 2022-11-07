#################### This script categorises the retained spatial data points occording to the area of their plate #####################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


store <- xy[-MAX, 1:2] #store will be the dataframe containing the plate ID assigned to each point according to the 3 models (all without Seton)
colnames(store) <- c("lon_0", "lat_0")

for(mdl in models){
  cells_ID_mod <- readRDS(paste0('./data/georeferenced/', mdl, '.RDS'))[-MAX, c("georef")]
  cat_ref <- readRDS(paste0("./data/plate_areas/", mdl,"_plates_categorised.RDS"))
  cat_mod <- rep(0, length(cells_ID_mod))
  for(i in 1:nrow(cat_ref)){
    plate <- cat_ref$PLATE_ID[i]
    cat_mod[which(cells_ID_mod == plate)] = cat_ref$CATEGORY[i]
  }
  store[, c(paste0(mdl, "_plate_cat"))] = cat_mod
}

store$cross_cat <- apply(X = store[, c("Scotese2_plate_cat", "Wright_plate_cat", "Matthews_plate_cat")],
                         MARGIN = 1,
                         FUN = sum) 

proj_moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0"  #mollweide

par(mfrow = c(1,3))
for(col in seq(from = 3, to = 5, by = 1)){
  r <- rasterFromXYZ(store[,c(1,2,col)], crs = "+proj=longlat +datum=WGS84")
  p <- projectRaster(r, crs = proj_moll)
  plot(p, col = c("#fee391", "#fe9929", "#662506"), axes = FALSE, main = models[col-2], legend = FALSE)
  plot(worldline_mol, add = TRUE)
}

saveRDS(store, file = "./data/plate_areas/cross_categorisation.RDS")
