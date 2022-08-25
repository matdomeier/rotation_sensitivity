################### This script computes the correlation tables between estimates of the four models in terms of subtropical limit #######################


# Author: Lucas Buffan
# e-mail: Lucas.L.Buffan@gmail.com
# Copyright (c): Lucas Buffan, 2022


models <- c("Wright", "Seton", "Matthews", "Scotese")


get_max_tax <- function(taxon){ #returns a table with max absolute palaeolatitude for each time step (each series of each model will be further analysed in the correlatio analysis)
  data_ex <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/10Myrs_time_bins/Scotese.RDS"))
  MAXI <- data.frame(time = sort(unique(data_ex$TB))[-which(sort(unique(data_ex$TB)) > 200)])
  for(mdl in models){
    data <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/10Myrs_time_bins/", mdl, ".RDS"))
    maxi <- c()
    for(t in MAXI$time){
      COL <- paste0("lat_", t)
      indexes <- which(is.na(data[, c(COL)]) == FALSE)
      lat <- abs(data[indexes, c(COL)])
      maxi <- c(maxi, max(abs(lat)))
    }
    MAXI[, c(mdl)] <- maxi
  }
  return(MAXI)
}


get_cor_tax <- function(taxon, metric){ #correlation analysis out of the list of the max abs lat assessed in the previous function
  df <- get_max_tax(taxon)
  COR <- data.frame(Wright = rep(0,4),
                    Seton = rep(0,4),
                    Matthews = rep(0,4),
                    Scotese = rep(0,4))
  rownames(COR) <- models
  for(mdl in models){
    cor_mod <- c()
    for(mdl1 in models){
      if(metric == "r"){ #retrun 
        cor_mod <- c(cor_mod, cor.test(x = df[, c(mdl)], y = df[, c(mdl1)], method = "pearson")$estimate)
      }
      else if(metric == "p"){
        cor_mod <- c(cor_mod, cor.test(x = df[, c(mdl)], y = df[, c(mdl1)], method = "pearson")$p.value)
      }
      else{
        warning("metric has to be either 'r' (Pearson's R) or 'p' (p-value) ")
      }
    }
    COR[, c(mdl)] <- cor_mod
  }
  return(COR)
}


COR_REEFS <- get_cor_tax("corals")
COR_CROCOS <- get_cor_tax("crocos") 
