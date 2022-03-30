############## This script plots the crocodiles reconstructed palaeocoordinates according to the 4 different models ##################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Libraries ---------------------------------------------------------------------------------------------
library(ggplot2)
library(rphylopic)

palette <- c("#33a02c", "#fb9a99", "#e31a1c", "#fdbf6f")
models <- c("GOLONKA", "SETON2012", "MATTHEWS2016", "PALEOMAP")

silhouettes <- c("d148ee59-7247-4d2a-a62f-77be38ebb1c7", #Cnidaria
                 "dffda000-77cb-4251-b837-0cd2ab21ed5b") #Crocodylia



## THE BIG FUNCTION --------------------------------------------------------------------------------------
make_plots <- function(taxon){ #taxon = Crocos or Corals
  
  if(taxon == "Crocos"){
    yrange <- c(20, 83)
    phylo_coords <- c(-33, 80)
    img <- image_data(silhouettes[[2]], size = 512)[[1]]
    fill_col <- "#41ab5d"
  }
  else if(taxon == "Corals"){
    yrange <- c(10, 60)
    phylo_coords <- c(-8, 55)
    img <- image_data(silhouettes[[1]], size = 512)[[1]]
    fill_col <- "#ef6548"
  }
  
  data_ex <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/PALEOMAP.RDS"))
  coverage <- sort(unique(data_ex$AGE))[-which(sort(unique(data_ex$AGE)) > 200)] #we constrain ourselves to the early jurassic
  
  TIME <- c()
  MAXI <- c() #these vectors will contain the max and min of the reconstructed latitudes according to the model => extent of intertropical belt
  MINI <- c()
  GROUP <- c()
  for(mdl in models){
    data <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/true_MidAge/", mdl, ".RDS"))
    GROUP <- c(GROUP, rep(mdl, length(coverage)))
    for(t in coverage){
      dex <- which(data$AGE == t)
      lat <- data[dex, c("PALEO_LAT")]
      MAXI <- c(MAXI, max(lat))
      MINI <- c(MINI, min(lat))
      TIME <- c(TIME, t)
    }
  }
  to_plot <- data.frame(TIME = TIME,
                        lat_max = MAXI,
                        lat_min = MINI,
                        GROUP = GROUP)
  
  ######################## Plot with the 4 models reconstruction of the Northern limit of the (sub)tropical zone (max lat occurrence)######################
  northern_border <- ggplot(data = to_plot, aes(x = TIME, y = lat_max, group = GROUP, color = factor(GROUP))) +
    geom_point() +
    ggtitle(paste0("Northern (sub)tropical limit based on ", taxon)) +
    scale_x_reverse(breaks = seq(from = 0, to = 200, by = 50)) +
    scale_y_continuous(limits = c(yrange[1], yrange[2]), 
                       breaks = seq(from = yrange[1]+10, to = yrange[2], by = 10), 
                       labels = seq(from = yrange[1]+10, to = yrange[2], by = 10))+
    scale_colour_manual(values = palette, name = "Model") +    
    geom_line(lwd = 1) +
    theme(text = element_text(size = 22),
          plot.title = element_text(size = 20),
          axis.text.x = element_text(size = 19),
          axis.text.y = element_text(size = 19),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          panel.background = element_blank(),
          panel.border = element_rect(colour = "black", fill = NA, size = 0.5)) + #frame the plot
    labs(x = "Time (Ma)", y = "Latitude (°)") +
    annotate("rect", xmin = Inf, xmax = 200, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")+
    annotate("rect", xmin = 200, xmax = 145, ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "grey40")+
    annotate("rect", xmin = 200, xmax = 145, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (200+145)/2, y = yrange[1]+0.5, label = "Ju", size = 7)+
    annotate("rect", xmin = 145, xmax = 66, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (145+66)/2, y = yrange[1]+0.5, label = "Cr", size = 7)+
    annotate("rect", xmin = 66, xmax= 23.03, ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "grey40")+
    annotate("rect", xmin = 66, xmax = 23.03, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (66+23.03)/2, y = yrange[1]+0.5, label = "Pg", size = 7)+
    annotate("rect", xmin = 23.03, xmax = 2.58, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (23.03+2.58)/2, y = yrange[1]+0.5, label = "Ng", size = 7)+
    annotate("rect", xmin = 2.58, xmax = -Inf, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")
  
  ggsave(filename = paste0("./figures/case_study/", taxon, "/lat_north_bound_4mdl_1Myrs_step.pdf"),
         plot = northern_border,
         height = 5,
         width = 9)
  
  ####################### Now, constrain to represent the min and max of each slice ######################
  mx <- c()
  mn <- c()
  md <- c()
  for(t in coverage){
    indexes <- which(to_plot$TIME == t)
    mx <- c(mx, max(to_plot$lat_max[indexes]))
    mn <- c(mn, min(to_plot$lat_max[indexes]))
    md <- c(md, median(to_plot$lat_max[indexes]))
  }
  
  tax_range <- data.frame(time = coverage,
                          max = mx,
                          min = mn,
                          median = md)
  
  dist_plot <- ggplot(data = tax_range, aes(x = time, y = mx)) +
    scale_x_reverse(breaks = seq(from = 0, to = 200, by = 50))+
    geom_line(aes(y = mx), linetype = "solid", lwd = 1.2)+
    geom_line(aes(y = mn), linetype = "solid", lwd = 1.2)+
    geom_line(aes(y = md), linetype = "dashed", lwd = 1) +
    geom_ribbon(aes(ymin = mn, ymax = mx), fill = fill_col, alpha = 0.7)+
    scale_y_continuous(limits = c(yrange[1], yrange[2]), 
                       breaks = seq(from = yrange[1]+10, to = yrange[2], by = 10), 
                       labels = seq(from = yrange[1]+10, to = yrange[2], by = 10))+
    ggtitle(paste0("Northern (sub)tropical limit based on ", taxon))+
    add_phylopic(img, alpha = 1, x = phylo_coords[1], y = phylo_coords[2], ysize = 10)+
    theme(text = element_text(size = 25),
          plot.title = element_text(size = 20),
          axis.text.x = element_text(size = 23),
          axis.text.y = element_text(size = 23),
          panel.grid.major = element_blank(), # Remove panel grid lines
          panel.grid.minor = element_blank(), 
          panel.background = element_blank(), # Remove panel background
          panel.border = element_rect(colour = "black", fill = NA, size = 1))+
    labs(x = "Time (Ma)", y= "Latitude (°)") +
    annotate("rect", xmin = Inf, xmax = 200, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")+
    annotate("rect", xmin = 200, xmax = 145, ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "grey40")+
    annotate("rect", xmin = 200, xmax = 145, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (200+145)/2, y = yrange[1]+0.5, label = "J", size = 7)+
    annotate("rect", xmin = 145, xmax = 66, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (145+66)/2, y = yrange[1]+0.5, label = "K", size = 7)+
    annotate("rect", xmin = 66, xmax= 23.03, ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "grey40")+
    annotate("rect", xmin = 66, xmax = 23.03, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (66+23.03)/2, y = yrange[1]+0.5, label = "Pg", size = 7)+
    annotate("rect", xmin = 23.03, xmax = 2.58, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (23.03+2.58)/2, y = yrange[1]+0.5, label = "Ng", size = 7)+
    annotate("rect", xmin = 2.58, xmax = -Inf, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white")
  
  ggsave(filename = paste0("./figures/case_study/", taxon, "/lat_north_bound_deviation_1Myrs_step.pdf"),
         plot = dist_plot,
         height = 5,
         width = 9)
  
}


## EXECUTION --------------------------------------------------------------------------------------------------------

for(taxon in c("Corals", "Crocos")){
  make_plots(taxon)
}

