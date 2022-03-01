################# This script parallelises the computation of the MST length #####################

## Parallelisation libraries --------------------------------------------------------------------------------------
library(parallel)
library(MASS)
library(vegan, geosphere)

## Get cores number ----------------------------------------------------------------------------------------------
nCores <- detectCores()


## Timescale ------------------------------------------------------------------------------------------------------
Timescale <- seq(from = 10, to = 540, by = 10) #The timescale of the study will the upper bound of the models going deeper in time: SETON, 540Ma


## OUTPUTS OF THE FOUR MODELS -------------------------------------------------------------------------------------
GOLONKA <- readRDS('./data/extracted_paleocoordinates/Golonka.RDS')[-MAX,] #we directly get rid of the elements that are not further treated, to lower computing time
SETON <- readRDS('./data/extracted_paleocoordinates/Seton.RDS')[-MAX,]
SETON[, seq(from = ncol(SETON), to = 2*(max(Timescale)/10+1), by = 1)] = NA #temporal scaling: we artificially extend the duration of SETON and MATTHEWS so we could assess MST until 540Ma (vegan ignores NAs)
MATTHEWS <- readRDS('./data/extracted_paleocoordinates/Matthews.RDS')[-MAX,]
MATTHEWS[, seq(from = ncol(MATTHEWS), to = 2*(max(Timescale)/10+1), by = 1)] = NA 
SCOTESE <- readRDS('./data/extracted_paleocoordinates/Scotese2.RDS')[-MAX,]


## Compute th MST assessment with a parallelisation step involving the nb of cores of the machine -----------------
MST_mat <- matrix(0,
                  nrow = 64800 - length(unique(MAX)), 
                  ncol = length(Timescale)+2 #as many rows as we have time intervals + 2 supplementary for the coordinates
)
MST_df <- data.frame(MST_mat)
MST_df[, 1:2] <- GOLONKA[, 1:2] #coordinates
cnames <- c("lon_0", "lat_0")

  #Function that will be parallelised
MST_len <- function(i){
  dist_mat <- distm(rbind(cbind(GOLONKA[i, 2*t/10+1], GOLONKA[i, 2*t/10+2]), 
                          cbind(SETON[i, 2*t/10+1], SETON[i, 2*t/10+2]),
                          cbind(SCOTESE[i, 2*t/10+1], SCOTESE[i, 2*t/10+2]),
                          cbind(MATTHEWS[i, 2*t/10+1], MATTHEWS[i, 2*t/10+2])),
                    fun = distGeo)
  LENGTH = sum(spantree(dist_mat)$dist)/10**6 #in 10^3 km
  return(LENGTH)
}

  #make a cluster
cl <- makeCluster(nCores-1, type = "PSOCK")
cl <- clusterEvalQ(cl, {library(vegan)})

for(t in Timescale){
  cnames <- c(cnames, paste0("MST_length_", t))
  result <- parallel::parLapply(cl = cl,
                                X = seq(from = 1, to = 64800, by = 1),
                                fun = MST_len)
  
  MST_df[, t/10+2] = result
}

stopCluster(cl) #stop the cluster

colnames(MST_df) <- cnames

saveRDS(MST_df, "./data/MST_length.RDS")