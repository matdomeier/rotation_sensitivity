############ This script quantifies the amount of fossil occurrences (crocs and corals) located in a risky zon (high ID_sc or frames) ################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan
#e-mail: lucas.l.buffan@gmail.com


## Libraries -------------------------------------------------------------------
library(raster)
library(dplyr)

## Fossil data -----------------------------------------------------------------
corals <- readRDS("./data/occurrences/cleaned_Corals_dataset.RDS")[, c("lng", "lat")]
corals <- data.frame(apply(X = corals, MARGIN = c(1,2), FUN = round, digits = 1))

crocs <- readRDS("./data/occurrences/cleaned_Crocos_dataset.RDS")[, c("lng", "lat")]
crocs <- data.frame(apply(X = crocs, MARGIN = c(1,2), FUN = round, digits = 1))

## ID_sc and frames ------------------------------------------------------------
  #CARRIBEAN FRAME
FRAME1 <- list("lon_w" = -103, #longitude of the most eastern corner (in degrees)
               "lon_e" = -53,  #longitude of the most western corner
               "lat_n" = 32,   #latitude of the most northern corner
               "lat_s" = 5)    #latitude of the most southern corner

  #INDIAN FRAME
FRAME2 <- list("lon_w" = 54,
               "lon_e" = 98,
               "lat_n" = 38,
               "lat_s" = 15)

  #OCEANIAN FRAME
FRAME3 <- list("lon_w" = 112,
               "lon_e" = 137,
               "lat_n" = 23,
               "lat_s" = -13)

  #ID_SCORE FILE
store <- readRDS("./data/data_pts_plate_IDs_according_to_the_four_models.RDS")
r <- rasterFromXYZ(store[,c(1,2,6)], crs = "+proj=longlat +datum=WGS84")

ID_score_cor <- extract(x = r, y = corals) # extraction to assign an ID_score to each occurrence
ID_score_croc <- extract(x = r, y = crocs)


## Risk analysis ---------------------------------------------------------------

final <- data.frame(CORALS = c(length(which( (corals$lng %in% seq(from = -103, to = -53, by = 0.1))
                                             & (corals$lat %in% seq(from = 5, to = 32, by = 0.1) ))) / nrow(corals),
                               
                               length(which( (corals$lng %in% seq(from = 54, to = 98, by = 0.1))
                                             & (corals$lat %in% seq(from = 15, to = 38, by = 0.1) ))) / nrow(corals),
                               
                               length(which( (corals$lng %in% seq(from = 112, to = 137, by = 0.1))
                                             & (corals$lat %in% seq(from = -13, to = 23, by = 0.1) ))) / nrow(corals),
                               
                               length(which(ID_score_tax == 1))/nrow(corals),
                               length(which(ID_score_tax == 2))/nrow(corals),
                               length(which(ID_score_tax == 3))/nrow(corals)),
                    
                    CROCS = c(length(which( (crocs$lng %in% seq(from = -103, to = -53, by = 0.1))
                                          & (crocs$lat %in% seq(from = 5, to = 32, by = 0.1) ))) / nrow(crocs),
                              
                              length(which( (crocs$lng %in% seq(from = 54, to = 98, by = 0.1))
                                            & (crocs$lat %in% seq(from = 15, to = 38, by = 0.1) ))) / nrow(crocs),
                              
                              length(which( (crocs$lng %in% seq(from = 112, to = 137, by = 0.1))
                                            & (crocs$lat %in% seq(from = -13, to = 23, by = 0.1) ))) / nrow(crocs),
                              
                              length(which(ID_score_tax == 1))/nrow(crocs),
                              length(which(ID_score_tax == 2))/nrow(crocs),
                              length(which(ID_score_tax == 3))/nrow(crocs))
          )

rownames(final) = c("% occ in CAR frame",
                    "% occ in HIM frame",
                    "% occ in SEA frame",
                    "% occ in zones of ID_sc=1",
                    "% occ in zones of ID_sc=2",
                    "% occ in zones of ID_sc=3")
final