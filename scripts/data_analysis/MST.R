############## Compute the MST for each point of the grid we are working on ##############

#The MST length will be sort of an extension of the latitudinal deviation assessment
#Needs to be conjugated with a metric indicating whether the models +/- agree or not => variance of the average distance to the common centroid of the 4 estimates

library(geosphere)


## TIMESCALE  --------------------------------------------------------------------------------------------------------

Timescale <- seq(from = 10, to = 200, by = 10) #The timescale of the study will the upper bound of the model going shallower in time: SETON, 200Ma


## OUTPUTS OF THE FOUR MODELS ----------------------------------------------------------------------------------------

GOLONKA <- readRDS('./data/extracted_paleocoordinates/Golonka.RDS')[-MAX,] #we directly get rid of the elements that are not further treated, to lower computing time
SETON <- readRDS('./data/extracted_paleocoordinates/Seton.RDS')[-MAX,]
MATTHEWS <- readRDS('./data/extracted_paleocoordinates/Matthews.RDS')[-MAX,]
SCOTESE <- readRDS('./data/extracted_paleocoordinates/Scotese2.RDS')[-MAX,]



## LOOP for MST (loaf greedy algorithm) ------------------------------------------------------------------------------

#final matrix that will contain the MST length over time
MST_mat <- matrix(0,
                  nrow = 64800 - length(MAX), 
                  ncol = length(Timescale)+2 #as many wows as we have time intervals + 2 supplementary for the coordinates
                  )
MST_df <- data.frame(MST_mat)
MST_df[, 1:2] <- GOLONKA[, 1:2] #coordinates
cnames <- c("lon_0", "lat_0")

NAMES <- c("gol", "set", "sco", "mat")
L <- list()

for(t in seq(from = 120, to = 200, by = 10)){
  for(i in 1:nrow(MST_df)){
    
    L[["gol"]] <- c(GOLONKA[i, 2*t/10+1], GOLONKA[i, 2*t/10+2])
    L[["set"]] <- c(SETON[i, 2*t/10+1], SETON[i, 2*t/10+2])
    L[["sco"]] <- c(SCOTESE[i, 2*t/10+1], SCOTESE[i, 2*t/10+2])
    L[["mat"]] <- c(MATTHEWS[i, 2*t/10+1], MATTHEWS[i, 2*t/10+2])
    
    #we get the distance matrix
    Dissim <- matrix(0, nrow = 4, ncol = 4, dimnames = list(NAMES, NAMES)) #initialise dist matrix
    NAMES_copy <- NAMES
    k = 1
    while(k < length(NAMES)){
      name1 <- NAMES[[k]]
      for(name2 in NAMES_copy){
        if(name2 != name1){
          line <- rbind(L[[name1]], L[[name2]])
          len <- lengthLine(line)/1000 #convert in km
          Dissim[k, which(NAMES == name2)] <- len
        }
      }
      NAMES_copy <- NAMES_copy[-c(1)]
      k = k+1
    }
    
     
    sorting <- sort(Dissim) #we sort its values in increasing order
    sort_no_0 <- sorting[-c(which(sorting == 0))] #exclude zeros
    MST_length <- sum(sort_no_0[1:3]) #select the 3 smallest values and sum them: we have our MST length (greedy algorithm)
    
    MST_df[i, t/10+2] <- MST_length
  }
}

for(t in T){
  cnames <- c(cnames, paste0("MST_length_", t))
}

colnames(MST_df) <- cnames

saveRDS(MST_df, "./data/MST_length_loaf.RDS")



## MST with Lewis' delicate method -------------------------------------------------------------------------------

library(vegan)

MST_mat <- matrix(0,
                  nrow = 64800 - length(unique(MAX)), 
                  ncol = length(Timescale)+2 #as many wows as we have time intervals + 2 supplementary for the coordinates
)
MST_df <- data.frame(MST_mat)
MST_df[, 1:2] <- GOLONKA[, 1:2] #coordinates
cnames <- c("lon_0", "lat_0")

for(t in Timescale){
  cnames <- c(cnames, paste0("MST_length_", t))
  for(i in 1:nrow(MST_df)){
    dist_mat <- distm(rbind(cbind(GOLONKA[i, 2*t/10+1], GOLONKA[i, 2*t/10+2]), 
                              cbind(SETON[i, 2*t/10+1], SETON[i, 2*t/10+2]),
                              cbind(SCOTESE[i, 2*t/10+1], SCOTESE[i, 2*t/10+2]),
                              cbind(MATTHEWS[i, 2*t/10+1], MATTHEWS[i, 2*t/10+2])),
                       fun = distGeo)
    MST_df[i, t/10+2] = sum(spantree(dist_mat)$dist)/1000 #in km
  }
}
colnames(MST_df) <- cnames

saveRDS(MST_df, "./data/MST_length.RDS")



data.frame()



t = 10
i = 2
dist_mat <- distm(rbind(cbind(GOLONKA[i, 3], GOLONKA[i, 4]), 
                          cbind(SETON[i, 3], SETON[i, 4]),
                          cbind(SCOTESE[i, 3], SCOTESE[i, 4]),
                          cbind(MATTHEWS[i, 3], MATTHEWS[i, 4])),
                   fun = distGeo)
MST <- length(spantree(dist_mat))
MST_df[, t/10+2] = lapply(MSTs, FUN = length)


rbind(cbind(GOLONKA[i, 3], GOLONKA[i, 4]), 
      cbind(SETON[i, 3], SETON[i, 4]),
      cbind(SCOTESE[i, 3], SCOTESE[i, 4]),
      cbind(MATTHEWS[i, 3], MATTHEWS[i, 4]))




gcdists <- distm(cbind(out$palaeolng, out$palaeolat), fun = distGeo)
mst_sp <- spantree(gcdists)

