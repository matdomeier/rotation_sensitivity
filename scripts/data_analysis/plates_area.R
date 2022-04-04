##################### This script assesses and saves the area of different plates of the different models ###################### 


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


library(raster)

models <- c("Scotese2", "Wright", "Matthews")

get_area <- function(shp){ #for some reason, polygon areas are given in x10^4 km²!! (verification: dividing the sum of the list for scotese areaby an approximation of the area of the earth, 4*pi*6379² gives ~10^(-4))
  return(shp@Polygons[[1]]@area)
}

## Plates visulisation ---------------------------------------------------------
par(mfrow = c(1,3))
for(mdl in models){
  shape <- shapefile(paste0("./data/continental_polygons/", mdl, "/", mdl, "_PresentDay_ContinentalPolygons.shp"))
  L <- lapply(X = shape@polygons, FUN = get_area)
  hist(x = as.numeric(L), main = paste0(mdl, " (n=", length(L), " plates)"), xlab = "Polygons area (x10^4 km²)", breaks = seq(from = 0, to = 8000, by = 50))
}


## Arbitrary classification by size: -------------------------------------------
      #Major Plates (>20M km²), 
      #Minor Plates(between 20M and 1M km²)
      #Microplates (<1M km²)

cat_plates <- function(vect){ #vect is a vector of tectonic plates Areas. This function returns the category of each plate
  cat <- rep(0, length(vect))
  cat[which(vect >= 2000)] = 1 #MAJOR
  cat[which((vect < 2000) & (vect >= 100))] = 2 #MINOR
  cat[which(vect < 100)] = 3 #MICRO
  return(cat)
}

for(mdl in models){
  shape <- shapefile(paste0("./data/continental_polygons/", mdl, "/", mdl, "_PresentDay_ContinentalPolygons.shp"))
  areas <- unlist(lapply(X = shape@polygons, FUN = get_area))
  IDs <- shape@data$PLATEID1
  cat <- cat_plates(areas)
  df <- data.frame(PLATE_ID = IDs,
                   PLATE_AREA = areas,
                   CATEGORY = cat)
  saveRDS(df, file = paste0("./data/plate_areas/", mdl,"_plates_categorised.RDS"))
}

