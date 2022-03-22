################### This file plots the distances between all the points according to the four models #######################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Libraries ---------------------------------------------------------------------------------------------
library(ggplot2)
library(rphylopic)
library(abind)


## Plot --------------------------------------------------------------------------------------------------
taxon <- "Crocos"
models <- c("Wright", "Seton", "Matthews", "Scotese")
silhouettes <- c("d148ee59-7247-4d2a-a62f-77be38ebb1c7", #Cnidaria
                 "dffda000-77cb-4251-b837-0cd2ab21ed5b") #Crocodylia
palette <- c("#33a02c", "#fb9a99", "#e31a1c", "blue")


data_ex <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/Scotese.RDS"))
coverage <- sort(unique(data_ex$TB))[-which(sort(unique(data_ex$TB)) > 200)] #the time coverage: all the bins under 200Ma

TIME <- c()
GROUP <- c() #SPECIFY TIME AND GROUP SO THEY END SAME LENGTH AS LAT
LAT <- c()

#We get the indexes of the cells corresponding to fossils older than 195Ma
indexes <- c()
for(i in 1:nrow(data_ex)){
  L <- length(which(is.na(data_ex[i, seq(from = ncol(data_ex)-7, to = ncol(data_ex), by = 1)]) == FALSE))
  if(L>0){
    indexes <- c(indexes, i)
  }
} #length(indexes) = 66 for crocos, 5 for corals



for(mdl in models){
  print(mdl)
  data <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/", mdl, ".RDS"))
  data <- data[-indexes, ] #filter rows for fossils going further than 195Ma 
  data <- data[, -c(1, seq(from = ncol(data)-7, to = ncol(data), by = 1))] #erase TB column and all time older than 195Ma
  data <- data[, -c(which(seq(from = 1, to = ncol(data), by = 1) %% 2 != 0))] #erase odd column indexes, corresponding to longitudes
  lat <- c()
  time <- c()
  group <- c()
  for(t in coverage){
    COL <- paste0("lat_", t)
    print(COL)
    IND <- which(is.na(data[, c(COL)]) == FALSE)
    lat <- c(lat, data[IND, c(COL)])
    time <- c(time, rep(t, length(IND)))
    group <- c(group, rep(mdl, length(IND)))
  }
  LAT <- c(LAT, lat)
  TIME <- c(TIME, time)
  GROUP <- c(GROUP, group)
}


to_plot <- data.frame(TIME = TIME,
                      LAT = LAT,
                      GROUP = GROUP)

raw_scatter <- ggplot(data = to_plot, aes(x = TIME, y = LAT, group = GROUP, color = factor(GROUP)))+
  geom_point(size = 3) +
  ggtitle(taxon) +
  scale_x_reverse(breaks = seq(from = 0, to = 200, by = 50)) +
  scale_colour_manual(values = palette, name = "Model") +
  theme(text = element_text(size = 22),
        plot.title = element_text(size = 20),
        axis.text.x = element_text(size = 19),
        axis.text.y = element_text(size = 19),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA, size = 0.5)) + #frame the plot
  labs(x = "Time (Ma)", y = "Latitude (°)")

raw_scatter



df_comp <- data.frame(D = rep(1, 4539)) #initialisation column (4539 for crocos, 415 for corals)


for(mdl in models){
  data <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/", mdl, ".RDS"))
  data <- data[-indexes, ] #filter rows for fossils going further than 195Ma 
  data <- data[, -c(1, seq(from = ncol(data)-7, to = ncol(data), by = 1))] #erase TB column and all time older than 195Ma
  data <- data[, -c(which(seq(from = 1, to = ncol(data), by = 1) %% 2 != 0))] #erase odd column indexes, corresponding to longitudes
  lat <- c()
  time <- c()
  for(t in coverage){
    COL <- paste0("lat_", t)
    IND <- which(is.na(data[, c(COL)]) == FALSE)
    lat <- c(lat, data[IND, c(COL)])
    time <- c(time, rep(t, length(IND)))
  }
  df_comp[, c(mdl)] <- lat
}
df_comp$TIME <- time
df_comp <- df_comp[, -c(1)]
df_comp$length <- apply(X = df_comp[, models], MARGIN = 1,  FUN = max) - apply(X = df_comp[, models], MARGIN = 1,  FUN = min)
df_comp$med <- apply(X = df_comp[, models], MARGIN = 1,  FUN = median)

t = 165
dni = which(df_comp$TIME == t)
plot(df_comp$med[dni], df_comp$length[dni])

heatmap <- ggplot(data = df_comp, aes(x = TIME, y = med, fill = length))+
  geom_tile()

heatmap
