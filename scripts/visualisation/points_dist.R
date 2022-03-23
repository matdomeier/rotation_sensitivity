################### This file plots the distances between all the points according to the four models #######################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Libraries ---------------------------------------------------------------------------------------------
library(ggplot2)
library(rphylopic)
library(abind)


## Data --------------------------------------------------------------------------------------------------
taxon <- "Crocos"
models <- c("PALEOMAP",
            "SETON2012",
            "MATTHEWS2016",
            "GOLONKA")
silhouettes <- c("d148ee59-7247-4d2a-a62f-77be38ebb1c7", #Cnidaria
                 "dffda000-77cb-4251-b837-0cd2ab21ed5b") #Crocodylia
palette <- c("#33a02c", "#fb9a99", "#e31a1c", "blue")


data_ex <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/PALEOMAP.RDS"))
over_timed <- which(data_ex$AGE > 200) #indexes of teh occurrences older than 200Ma

## Raw scatter plot --------------------------------------------------------------------------------------
data <- c()
for(mdl in models){
  df_mod <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/", mdl, ".RDS"))[-over_timed,
                                                                                                              c("AGE", "PALEO_LON", "PALEO_LAT")]
  group <- rep(mdl, nrow(df_mod))
  df_mod <- cbind(df_mod, group)
  data <- rbind(data, df_mod)
}

colnames(data) <- c("AGE", "PALEO_LON", "PALEO_LAT", "GROUP")

raw_scatter <- ggplot(data = data, aes(x = AGE, y = PALEO_LAT, group = GROUP, color = factor(GROUP)))+
  geom_point(size = 3) +
  ggtitle(taxon) +
  scale_x_reverse(breaks = seq(from = 0, to = 200, by = 50)) +
  scale_colour_manual(values = palette, name = "Model") +
  theme(text = element_text(size = 22),
        plot.title = element_text(size = 20),
        axis.text.x = element_text(size = 19),
        axis.text.y = element_text(size = 19),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA, size = 0.5)) + #frame the plot
  labs(x = "Time (Ma)", y = "Latitude (°)")

raw_scatter


## Plot median max min -----------------------------------------------------------------------------------
data <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/PALEOMAP.RDS"))[-over_timed,"PALEO_LAT"]
for(mdl in models[-c(1)]){
  data <- cbind(data, readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/", mdl, ".RDS"))[-over_timed, c("PALEO_LAT")])
}
colnames(data) <- c("Scotese_lat", "Seton_lat", "Matthews_lat", "Wright_lat")
data <- data.frame(data)
data$TIME <- data_ex$AGE[-over_timed]
data$med_lat <- apply(X = data[, 1:4], MARGIN = 1, FUN = median, na.rm = T)
data$MAX <- apply(X = data[, 1:4], MARGIN = 1, FUN = max, na.rm = T)
data$MIN <- apply(X = data[, 1:4], MARGIN = 1, FUN = min, na.rm = T)

if(taxon == "Corals"){
  data <- data[-c(193, 206, 230),]
  fill_col <- "#ef6548"
}

if(taxon == "Crocos"){
  fill_col <- "#41ab5d"
}

distrib_plot <- ggplot(data = data, aes(x = TIME, y = med_lat)) +
  geom_point(colour = fill_col) +
  geom_errorbar(aes(ymin = MIN, ymax = MAX), colour = fill_col) +
  ggtitle(taxon) +
  scale_x_reverse(breaks = seq(from = 0, to = 200, by = 50)) +
  theme(text = element_text(size = 22),
        plot.title = element_text(size = 20),
        axis.text.x = element_text(size = 19),
        axis.text.y = element_text(size = 19),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA, size = 0.5)) +
  labs(x = "Time (Ma)", y = "Latitude (°)")

distrib_plot
