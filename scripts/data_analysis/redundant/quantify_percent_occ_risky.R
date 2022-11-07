############ This script quantifies the amount of fossil occurrences (crocs and corals) located in a risky zon (high ID_sc) ################


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


## ID_score file and attribution of plateIDs to occurrences -------------------- 
store <- readRDS("./data/data_pts_plate_IDs_according_to_the_four_models.RDS")
r <- rasterFromXYZ(store[,c(1,2,6)], crs = "+proj=longlat +datum=WGS84")

ID_score_cor <- extract(x = r, y = corals) # extraction to assign an ID_score to each occurrence
ID_score_croc <- extract(x = r, y = crocs)


##Output dataframe -------------------------------------------------------------
prop <- data.frame(CORALS = c(length(which(ID_score_cor == 1))/nrow(corals), 
                              length(which(ID_score_cor == 2))/nrow(corals), 
                              length(which(ID_score_cor == 3))/nrow(corals)),
                   CROCS = c(length(which(ID_score_croc == 1))/nrow(crocs),
                             length(which(ID_score_croc == 2))/nrow(crocs), 
                             length(which(ID_score_croc == 3))/nrow(crocs)))

rownames(prop) <- c("% occ in zones of ID_sc=1",
                    "% occ in zones of ID_sc=2",
                    "% occ in zones of ID_sc=3")

print(prop)
