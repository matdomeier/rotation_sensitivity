#---------------------------------------------------------------------
# Date: 2022-03-10
# Author: Lewis A. Jones
# Copyright (c) Lewis A. Jones, 2022
# Email: LewisA.Jones@outlook.com
#
# Script name:
# prepare_fossil_croc_data.R
# Script description:
# Data preparation and cleaning of Crocodylomorpha occurrence data set
#---------------------------------------------------------------------
#load libraries needed for script
library(dplyr)
library(tibble)

#---------------------------------------------------------------------
#Download all Crocodylomorpha occurrences from the Paleobiology Database (https://paleobiodb.org/#/) using the API service

#FOR SOME REASON, THE LINK TENDS NOT TO WORK SO PLEASE DIRECTLY OPEN THE SAVED FILE
#data <- read.csv("https://paleobiodb.org/data1.2/occs/list.csv?base_name=Crocodylomorpha&show=class&show=coords") #show = coords to show coordinates

#save raw data

#saveRDS(data, "./data/occurrences/raw_croc_dataset.RDS")

data <- readRDS(file = "./data/occurrences/raw_croc_dataset.RDS")
#Analyses focused on terrestrial taxa, load text file and remove all marine taxa from database
marine_taxa <- read.delim("./data/occurrences/marine_taxa.txt", header = FALSE)[,1]
#filter data from PBDB classification
data <- data %>% filter(!family %in% marine_taxa) #filter subsets dataframe according to the condition indicated
data <- data %>% filter(!genus %in% marine_taxa)
data <- data %>% filter(!accepted_name %in% marine_taxa)
#remove all form and ichnotaxa occurrence data
data <- data %>% filter(!flags %in% c("IF", "F", "I"))
#add mid_ma col
data <- data %>% add_column(mid_ma = (data$max_ma+data$min_ma)/2, .before = "min_ma")

#TIME BINNING----------------------------------------------------------
#assign to 10 myr time bins

#create empty columns for populating
data$bin_mid_ma <- NA

#whole of Phanerozoic
lower <- seq(from = 540, to = 10, by = -10)
mid <- seq(from = 535, to = 5, by = -10)
upper <- seq(from = 530, to = 0, by = -10)

#assign bins to data
for(i in 1:length(upper)){
  data[which(data$mid_ma < lower[i] & data$mid_ma > upper[i]),c("bin_mid_ma")] <- mid[i]
}

#SPATIAL CLEANING ------------------------------------------------------
r <- raster(res = 1) #start with a 1x1 raster
pos <- xyFromCell(object = r, cell = 1:ncell(r))  #extract coordinates as a df
xy <- data.frame(pos)
xy <- xy[-MAX, ]
xy$z <- 0 #z column, no use but required by rasterfromXYZ
rast <- rasterFromXYZ(xy)

#eliminate elements of data that have no value in rast, i.e fall out of the plotting zone
L = which(is.na(extract(x = rast, y = data[, c("lng", "lat")])) == T)
data1 <- data[-L, ] #75 occurrences filtered out

#visual validation (uncomment if you want to run it)
 plot(rast, legend = F, xaxt = "n", yaxt = "n")
# points(data[, c("lng", "lat")]) #all occurrences
# 
# plot(rast, legend = F, xaxt = "n", yaxt = "n")
# points(data1[, c("lng", "lat")]) #only spatially covered ones

#SAVE DATA--------------------------------------------------------------
saveRDS(data1, "./data/occurrences/cleaned_Crocos_dataset.RDS")
