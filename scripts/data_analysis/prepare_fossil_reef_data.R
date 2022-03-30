#-------------------------------------------------------------------------------
#
# Date: 2022-03-10
# Author: Lewis A. Jones
# Copyright (c) Lewis A. Jones, 2022
# Email: LewisA.Jones@outlook.com
#
# Script name:
# prepare_fossil_reef_data.R
#
# Script description:
# Prepare fossil reef occurrence data
#
#-------------------------------------------------------------------------------
#Load libraries, functions and analyses options
library(dplyr)
library(stringr)
#-------------------------------------------------------------------------------
#Load PARED data
PARED <- readRDS("./data/occurrences/raw_PARED_06_10_2021.RDS")
#-------------------------------------------------------------------------------
#PREPARE PARED DATA
#retain only coral reefs
PARED <- subset(PARED, biota_main_t == "Corals" | biota_sec_text == "Corals")
#retain only outcropping reefs (subsurface reefs unreliable for affiliation)
PARED <- subset(PARED, subsurface_text == "Outcropping reef")
#retain only true reefs
PARED <- subset(PARED, type_text == "True reef")
#remove cold water/temperate coral reefs
PARED <- subset(PARED, tropical_text == "Tropical or unknown")
#assign mid-age
PARED$mid_ma <- (PARED$max_ma+PARED$min_ma)/2
#retain only Scleractinian reefs 
PARED <- PARED[sapply(colnames(PARED), function(x) grep("Scleractinia", PARED[,x]))$biota_deta_text,]
#remove any coral reefs older than Anisian (247.2 Ma) as these imply non-scleractinian reefs
PARED <- subset(PARED, max_ma < 247.2)
#TIME BINNING-------------------------------------------------------------------
#assign to 10 myr time bins
#create empty columns for populating
PARED$bin_mid_ma <- NA
#whole of Phanerozoic
lower <- seq(from = 540, to = 10, by = -10)
mid <- seq(from = 535, to = 5, by = -10)
upper <- seq(from = 530, to = 0, by = -10)
#assign bins to data
for(i in 1:length(upper)){
  PARED[which(PARED$mid_ma < lower[i] & PARED$mid_ma > upper[i]),c("bin_mid_ma")] <- mid[i]
}
names(PARED)[names(PARED) == c("latit")] <- "lat" 
names(PARED)[names(PARED) == c("longit")] <- "lng" #rename these columns to make it easier for the rest of the analysis

#Eliminate data out of the spatial extent of the project (29500 cells)
    #re-generate a grid imputed from the cells we eliminate (indexes in MAX vector)
r <- raster(res = 1) #start with a 1x1 raster
pos <- xyFromCell(object = r, cell = 1:ncell(r))  #extract coordinates as a df
xy <- data.frame(pos)
xy <- xy[-MAX, ]
xy$z <- 0 #z column, no use but required by rasterfromXYZ
rast <- rasterFromXYZ(xy)

    #eliminate elements of PARED that have no value in rast, i.e fall out of the plotting zone
L = which(is.na(extract(x = rast, y = PARED[, c("lng", "lat")])) == T)
PARED1 <- PARED[-L, ] #75 occurrences filtered out

    #visual validation (uncomment if you want to run it)
# plot(rast, legend = F, xaxt = "n", yaxt = "n")
# points(PARED[, c("lng", "lat")]) #all occurrences
# 
# plot(rast, legend = F, xaxt = "n", yaxt = "n")
# points(PARED1[, c("lng", "lat")]) #only spatially covered ones

#SAVE DATA----------------------------------------------------------------------
saveRDS(PARED1, "./data/occurrences/cleaned_Corals_dataset.RDS")