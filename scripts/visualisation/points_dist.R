################### This file plots the distances between all the points according to the four models #######################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Libraries ---------------------------------------------------------------------------------------------
library(ggplot2)
library(abind)

## Data --------------------------------------------------------------------------------------------------
models <- c("PALEOMAP",
            "SETON2012",
            "MATTHEWS2016",
            "GOLONKA")


## function for the scatter plot --------------------------------------------------------------------------
scatter_plot <- function(taxon, plt){ #taxon = "Corals" or "Crocos"
  
  data_ex <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/PALEOMAP.RDS"))
  over_timed <- which(data_ex$AGE > 200) #indexes of teh occurrences older than 200Ma
  data <- c()
  for(mdl in models){
    df_mod <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/", mdl, ".RDS"))[-over_timed,
                                                                                                                c("AGE", "PALEO_LON", "PALEO_LAT")]
    group <- rep(mdl, nrow(df_mod))
    df_mod <- cbind(df_mod, group)
    data <- rbind(data, df_mod)
  }
  
  colnames(data) <- c("AGE", "PALEO_LON", "PALEO_LAT", "GROUP")
  
  ## Plot median max min -----------------------------------------------------------------------------------
  data <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/PALEOMAP.RDS"))[-over_timed,"PALEO_LAT"]
  for(mdl in models[-c(1)]){
    data <- cbind(data, readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/", mdl, ".RDS"))[-over_timed, c("PALEO_LAT")])
  }
  colnames(data) <- c("Scotese_lat", "Seton_lat", "Matthews_lat", "Wright_lat")
  data <- data.frame(data)
  data$TIME <- data_ex$AGE[-over_timed]

  if(taxon == "Corals"){
    data <- data[-c(112, 121, 142),]
    fill_col <- "#ef6548"
  }
  
  else if(taxon == "Crocos"){
    fill_col <- "#41ab5d"
  }
  data$med_lat <- apply(X = data[, 1:4], MARGIN = 1, FUN = median, na.rm = T)
  data$MAX <- apply(X = data[, 1:4], MARGIN = 1, FUN = max, na.rm = T)
  data$MIN <- apply(X = data[, 1:4], MARGIN = 1, FUN = min, na.rm = T)
  print(paste0("Number of ", taxon, " occurrences finally retained: ", nrow(data)))
  
  if(plt == T){
    distrib_plot <- ggplot(data = data, aes(x = TIME, y = med_lat)) +
      geom_errorbar(aes(ymin = MIN, ymax = MAX), colour = fill_col) +
      geom_point(colour = "black", fill = fill_col, alpha = 0.85, shape = 21) +
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
      labs(x = "Time (Ma)", y = "Latitude (°)") +
      scale_y_continuous(limits = c(-100, 83), 
                       breaks = c(-50, 0, 50), 
                       labels = c(-50, 0, 50)) +
      annotate("rect", xmin = Inf, xmax = 200, ymin = -Inf, ymax = -90, alpha = 1, color = "black", fill = "white")+
      annotate("rect", xmin = 200, xmax = 145, ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "grey40")+
      annotate("rect", xmin = 200, xmax = 145, ymin = -Inf, ymax = -90, alpha = 1, color = "black", fill = "white")+
      annotate("text", x = (200+145)/2, y = -98, label = "J", size = 7)+
      annotate("rect", xmin = 145, xmax = 66, ymin = -Inf, ymax = -90, alpha = 1, color = "black", fill = "white")+
      annotate("text", x = (145+66)/2, y = -98, label = "K", size = 7)+
      annotate("rect", xmin = 66, xmax= 23.03, ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "grey40")+
      annotate("rect", xmin = 66, xmax = 23.03, ymin = -Inf, ymax = -90, alpha = 1, color = "black", fill = "white")+
      annotate("text", x = (66+23.03)/2, y = -98, label = "Pg", size = 7)+
      annotate("rect", xmin = 23.03, xmax = 2.58, ymin = -Inf, ymax = -90, alpha = 1, color = "black", fill = "white")+
      annotate("text", x = (23.03+2.58)/2, y = -98, label = "Ng", size = 7)+
      annotate("rect", xmin = 2.58, xmax = -Inf, ymin = -Inf, ymax = -90, alpha = 1, color = "black", fill = "white")
  
    ggsave(filename = paste0("./figures/case_study/", taxon,"/", taxon, "_scatter_max_min_med.pdf"), plot = distrib_plot, height = 5, width = 9)
  }
  else{
    return(data)
  }
}


## Execute ---------------------------------------------------------------------

for(taxon in c("Corals", "Crocos")){
  scatter_plot(taxon, plt = TRUE)
}


## Histogram for temporal trends of deviation between models reconstructions ---

round_and_up <- function(x){
  return(trunc(x/10+1)*10)
}

cut_indexes <- list("Corals" = 25, "Crocos" = 35) #latitudinal threshold, under which we consider the occurrence in low and high latitude
fill_col <- list("Corals" = "#ef6548", "Crocos" = "#41ab5d") #colour to fill the boxplots

for(taxon in c("Corals", "Crocos")){
  cut_index <- cut_indexes[[taxon]] #this threshold was set arbitrarily for both taxa, in the view of the distribution of the absolute value of the reconstructed lat median
  data <- scatter_plot(taxon, plt = FALSE)
  data$time_binning <- unlist(lapply(X = data$TIME, FUN = round_and_up)) #assign occurrences to time bins
  data$space_binning[which(abs(data$med_lat) < cut_index)] <- "Low Latitude" #
  data$space_binning[which(abs(data$med_lat) >= cut_index)] <- "High Latitude"
  data$std <- apply(X = data[, c("Scotese_lat", "Seton_lat", "Matthews_lat", "Wright_lat")], MARGIN = 1, FUN = sd, na.rm = TRUE)
  
  #boxplot illutrating temporal trends of standard deviation between the four palaeolatitude reconstructions of each occurrence
  g1 <- ggplot(data, aes(x = TIME, y = std, group = time_binning)) +
    geom_boxplot(fill = fill_col[[taxon]], position = position_dodge()) +
    ggtitle(taxon) +
    scale_x_reverse() +
    theme(text = element_text(size = 22),
          plot.title = element_text(size = 20),
          axis.text.x = element_text(size = 19),
          axis.text.y = element_text(size = 19),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          panel.background = element_blank(),
          panel.border = element_rect(colour = "black", fill = NA, size = 0.5)) +
    ylim(0, 15) +
    labs(x = "Time (Ma)", y = "Latitude standard deviation (°)")
  ggsave(filename = paste0("./figures/case_study/temporal_trends/", taxon, "_time_boxplot.png"), plot = g1)
  
  #barplot to show the differences in std between "high latitude" and "low latitude" occurrences
  g2 <- ggplot(data, aes(x = time_binning, y = std, fill = space_binning, width = 5)) +
    geom_bar(stat = "identity", color = "black", position = position_dodge(5)) +
    ggtitle(taxon) +
    scale_x_reverse() +
    labs(x = "Time (Ma)", y = "Latitude standard deviation (°)")
  ggsave(filename = paste0("./figures/case_study/temporal_trends/", taxon, "_lat_cats_barplot.png"), plot = g2)
}


