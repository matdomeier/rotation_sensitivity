############## Compute the MST for each point of the grid we are working on ##############


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


#The MST length will be sort of an extension of the latitudinal deviation assessment
#Needs to be conjugated with a metric indicating whether the models +/- agree or not => variance of the average distance to the common centroid of the 4 estimates

library(geosphere)
library(vegan)


## TIMESCALE  --------------------------------------------------------------------------------------------------------

Timescale <- seq(from = 10, to = 540, by = 10) #The timescale of the study will the upper bound of the models going deeper in time: SETON, 540Ma


## OUTPUTS OF THE FOUR MODELS ----------------------------------------------------------------------------------------

WRIGHT <- readRDS('./data/extracted_paleocoordinates/Wright.RDS') #we directly get rid of the elements that are not further treated, to lower computing time
SETON <- readRDS('./data/extracted_paleocoordinates/Seton.RDS')
SETON[, seq(from = ncol(SETON), to = 2*(max(Timescale)/10+1), by = 1)] = NA #temporal scaling: we artificially extend the duration of SETON and MATTHEWS so we could assess MST until 540Ma (vegan ignores NAs)
MATTHEWS <- readRDS('./data/extracted_paleocoordinates/Matthews.RDS')
MATTHEWS[, seq(from = ncol(MATTHEWS), to = 2*(max(Timescale)/10+1), by = 1)] = NA 
SCOTESE <- readRDS('./data/extracted_paleocoordinates/Scotese2.RDS')



## MST with Lewis' delicate method -------------------------------------------------------------------------------

MST_mat <- matrix(0,
                  nrow = nrow(WRIGHT),  #as many rows as we have cells
                  ncol = length(Timescale)+2 #as many cols as we have time intervals + 2 supplementary for the coordinates
)
MST_df <- data.frame(MST_mat)
MST_df[, 1:2] <- WRIGHT[, 1:2] #coordinates
cnames <- c("lon_0", "lat_0")

for(t in Timescale){
  cnames <- c(cnames, paste0("MST_length_", t))
  for(i in 1:nrow(MST_df)){
    dist_mat <- distm(rbind(cbind(WRIGHT[i, 2*t/10+1], WRIGHT[i, 2*t/10+2]), 
                            cbind(SETON[i, 2*t/10+1], SETON[i, 2*t/10+2]),
                            cbind(SCOTESE[i, 2*t/10+1], SCOTESE[i, 2*t/10+2]),
                            cbind(MATTHEWS[i, 2*t/10+1], MATTHEWS[i, 2*t/10+2])),
                      fun = distGeo)
    MST_df[i, t/10+2] = sum(spantree(dist_mat)$dist)/10**6 #in 10^3 km
  }
}
colnames(MST_df) <- cnames

saveRDS(MST_df, "./data/MST_length.RDS")



