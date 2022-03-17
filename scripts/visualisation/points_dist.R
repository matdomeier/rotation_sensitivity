################### This file plots the distances between all the points according to the four models #######################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Libraries ---------------------------------------------------------------------------------------------
library(ggplot2)
library(rphylopic)


## Plot --------------------------------------------------------------------------------------------------
taxon <- "Crocos"
models <- c("Golonka", "Seton", "Matthews", "Scotese")
silhouettes <- c("d148ee59-7247-4d2a-a62f-77be38ebb1c7", #Cnidaria
                 "dffda000-77cb-4251-b837-0cd2ab21ed5b") #Crocodylia

data_ex <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/Scotese.RDS"))
coverage <- sort(unique(data_ex$TB))[-which(sort(unique(data_ex$TB)) > 200)] #the time coverage: all the bins under 200Ma

TIME <- rep(data_ex$TB, 4) #all dataframes of the four models are scaled and each row refers to the same occurrence
GROUP <- c()
LAT <- c()



for(mdl in models){
  data <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/", mdl, ".RDS"))
  GROUP <- c(GROUP, rep(mdl, nrow(data)))
  lat <- c()
  for(t in coverage){
    COL <- paste0("lat_", t)
    indexes <- which(is.na(data[, c(COL)]) == FALSE)
    lat <- c(lat, data[indexes, c(COL)])
  }
  LAT <- c(LAT, lat)
}


to_plot <- data.frame(TIME = TIME,
                      LAT = LAT,
                      GROUP = GROUP)

raw_scatter <- ggplot(data = to_plot, aes(x = TIME, y = LAT, group = GROUP))+
  geom_points()



for(mdl in models){
  data <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/", mdl, ".RDS"))
  GROUP <- c(GROUP, rep(mdl, nrow(data)))
  lat <- c()
  i = 1
  while(length(data) > 0){
    t = coverage[i]
    COL <- paste0("lat_", t)
    indexes <- which(is.na(data[, c(COL)]) == FALSE)
    lat <- c(lat, data[indexes, c(COL)])
    data <- data[-indexes, ]
    i = i+1
  }
  LAT <- c(LAT, lat)
}



L <- c()
for(i in 1:nrow(data_ex)){
  L <- c(L, length(which(is.na(data_ex[i, ]) == F)))
}

plot(L)


