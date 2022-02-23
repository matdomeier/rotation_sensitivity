############## Compute the MST for each point of the grid we are working on ##############

#The MST length will be sort of an extension of the latitudinal deviation assessment
#Needs to be conjugated with a metric indicating whether the models +/- agree or not => variance of the average distance to the common centroid of the 4 estimates

library(vegan)

## WORKING DIRECTORY --------------------------------

setwd('C:/Users/lucas/OneDrive/Bureau/Internship_2022/project/extracted_paleocoordinates')

## TIMESCALE  ---------------------------------------

Timescale <- seq(from = 10, to = 200, by = 10) #The timescale of the study will the upper bound of the model going shallower in time: SETON, 200Ma

## OUTPUTS OF THE FOUR MODELS -----------------------

GOLONKA <- read.csv('./Golonka.csv')[, -c(1)]
SETON <- read.csv('./Seton.csv')[, -c(1)]
MATTHEWS <- read.csv('./Matthews.csv')[, -c(1)]
SCOTESE <- read.csv('./Scotese2.csv')[, -c(1)]

## LOOP for MST -------------------------------------

cols <- c("G", "SC", "M", "SE")

for(t in Timescale){
  for(k in 1:nrow(SCOTESE)){  #do it directly for whole cols
    data <- data.frame(G = c(GOLONKA[k, 2*t/10+1], GOLONKA[k, 2*t/10+2]),
                       SC = c(SCOTESE[k, 2*t/10+1], SCOTESE[k, 2*t/10+2]),
                       M = c(MATTHEWS[k, 2*t/10+1], MATTHEWS[k, 2*t/10+2]),
                       SE = c(SETON[k, 2*t/10+1], SETON[k, 2*t/10+2]))
    i = 1
    cols_copy = cols
    
    while(i <= length(cols)){
      col1 <- colsls[[i]]
      for(col2 in cols_copy){
        if(col1 != col2){
          
        }
      }
      models_copy = models_copy[-1]  #we get rid of the new first element
      i = i+1
    }
    
  }
}



data(t)
dis <- vegdist(dune)
tr <- spantree(dis)
length(tr)
plot(tr, type = 't')


data <- data.frame(G = c(GOLONKA[1,2*t/10+1], GOLONKA[1,4]),
                   SC = c(SCOTESE[1,2*t/10+1], SCOTESE[1,4]),
                   M = c(MATTHEWS[1,2*t/10+1], MATTHEWS[1,4]),
                   SE = c(SETON[1,2*t/10+1], SETON[1,4]))

eucli_dist <- function(a, b){
  return(sqrt( (a[[1]] - b[[1]])**2 + (a[[2]] - b[[2]])**2 ))
}

eucli_dist(data$G, data$M)
data