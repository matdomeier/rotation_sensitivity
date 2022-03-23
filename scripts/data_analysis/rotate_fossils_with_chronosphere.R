################ This script rotates fossil occurrencres easily #####################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan
#e-mail: lucas.l.buffan@gmail.com


## Library ---------------------------------------------------------------------
library(chronosphere)
library(tibble)

## Let's dance -----------------------------------------------------------------
models <- c("PALEOMAP",
            "SETON2012",
            "MATTHEWS2016",
            "GOLONKA" #it says "coastlines only" though.. be careful. Also, this names refers to the WRIGHT!!
            )

for(taxon in c("Crocos", "Corals")){
  data <- readRDS(paste0("./data/occurrences/cleaned_", taxon, "_dataset.RDS")) #load occurrence dataset of the corresponding taxon
  data <- data %>% add_column(round_mid_ma = lapply(X = data$mid_ma, FUN = round, digits = 0), .before = "min_ma") #we add a column with the rounded mid-age to the closest million years unity, as reconstruct only works with integer times
  timescale <- sort(unique(unlist(data$round_mid_ma))) #this vector gives the number of different ages for which we are going to rotate occurrences
  for(mdl in models){
    TIME <- c()
    PALEOCOORD <- c()
    for(t in timescale){
      concerned <- which(data$round_mid_ma == t)
      TIME <- c(TIME, rep(t, length(concerned)))
      PALEOCOORD <- rbind(PALEOCOORD,
                          reconstruct(x = data[concerned, c("lng", "lat")],
                                      model = mdl,
                                      age = t))
    }
    final <- data.frame(AGE = TIME,
                        PRESENTDAY_LON = data$lng,
                        PRESENTDAY_LAT = data$lat,
                        PALEO_LON = PALEOCOORD[, 1],
                        PALEO_LAT = PALEOCOORD[, 2])
    saveRDS(object = final,
            file = paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/", mdl, ".RDS"))
  }
}

