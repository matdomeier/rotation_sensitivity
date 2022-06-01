############## This script plots the crocodiles reconstructed palaeocoordinates according to the 4 different models ##################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Libraries ---------------------------------------------------------------------------------------------
library(ggplot2)
library(rphylopic)
library(ggpubr)

models <- c("Wright", "Seton", "Matthews", "Scotese")

silhouettes <- c("d148ee59-7247-4d2a-a62f-77be38ebb1c7", #Cnidaria
                 "dffda000-77cb-4251-b837-0cd2ab21ed5b") #Crocodylia



## THE BIG FUNCTION --------------------------------------------------------------------------------------
make_plots <- function(taxon){ #taxon = Crocos or Corals
  
  if(taxon == "Crocos"){
    yrange <- c(20, 83)
    phylo_coords <- c(-30, 83)
    img <- image_data(silhouettes[[2]], size = 512)[[1]]
    fill_col <- "#41ab5d"
    xlab = "Time (Ma)"
    tax <- "Terrestrial Crocodylomorphs"
  }
  
  else if(taxon == "Corals"){
    yrange <- c(10, 73)
    phylo_coords <- c(-8, 55)
    img <- image_data(silhouettes[[1]], size = 512)[[1]]
    fill_col <- "#ef6548"
    xlab = NULL
    tax <- "warm-water Coral Reefs"
  }
  
  data_ex <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/10Myrs_time_bins/Scotese.RDS"))
  coverage <- sort(unique(data_ex$TB))[-which(sort(unique(data_ex$TB)) > 200)] #we constrain ourselves to the early jurassic
  
  TIME <- c()
  MAXI <- c() #this vectors will contain the max of the reconstructed latitudes IN ABSOLUTE VALUE according to each model. Assuming symmetry in tropics, this is going to return either the northern and the southern latitudinal limit of the tropics (abs)
  GROUP <- c()
  for(mdl in models){
    data <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/", taxon, "/10Myrs_time_bins/", mdl, ".RDS"))
    TIME <- c(TIME, sort(unique(data$TB)))
    GROUP <- c(GROUP, rep(mdl, length(coverage)))
    for(t in coverage){
      COL <- paste0("lat_", t)
      indexes <- which(is.na(data[, c(COL)]) == FALSE)
      lat <- abs(data[indexes, c(COL)])
      MAXI <- c(MAXI, max(lat))
    }
  }
  to_plot <- data.frame(TIME = coverage,
                        lat_max_per_model = MAXI,
                        GROUP = GROUP)
  
  #get the max and min between each of the four characterised maxima to further plot the uncertainty zone as a ribbon
  mx <- c()
  mn <- c()
  for(t in coverage){
    indexes <- which(to_plot$TIME == t) #length 4 as 4 models
    mx <- c(mx, max(to_plot$lat_max_per_model[indexes]))
    mn <- c(mn, min(to_plot$lat_max_per_model[indexes]))
  }
  
  to_plot$upper_boundary = rep(mx, 4)
  to_plot$lower_boundary = rep(mn, 4)
  
  ######################## Plot the 4 models reconstruction of the Northern limit of the subtropical zone (max |lat| occurrence with uncertainty zone)######################
  northern_border <- ggplot(data = to_plot, aes(x = TIME, y = lat_max_per_model, group = GROUP)) +
    geom_ribbon(aes(ymin = lower_boundary, ymax = upper_boundary), fill = fill_col, alpha = 0.5)+
    geom_point(aes(shape = factor(GROUP)), size = 3) +
    geom_line(lwd = 0.5) +
    ggtitle(paste0("Northern subtropical limit based on ", tax)) +
    add_phylopic(img, alpha = 1, x = phylo_coords[1], y = phylo_coords[2], ysize = 10)+
    scale_x_reverse(breaks = seq(from = 0, to = 200, by = 50)) +
    scale_y_continuous(limits = c(yrange[1], yrange[2]), 
                       breaks = seq(from = yrange[1]+10, to = yrange[2], by = 10), 
                       labels = seq(from = yrange[1]+10, to = yrange[2], by = 10))+
    theme(text = element_text(size = 22),
          plot.title = element_text(size = 20),
          axis.text.x = element_text(size = 19),
          axis.text.y = element_text(size = 19),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          panel.background = element_blank(),
          panel.border = element_rect(colour = "black", fill = NA, size = 2)) + #frame the plot
    labs(x = xlab, y = "Absolute palaeolatitude (°)", shape = "Model") +
    annotate("rect", xmin = Inf, xmax = 200, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white", size = 1.5)+
    annotate("rect", xmin = 200, xmax = 145, ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "grey40")+
    annotate("rect", xmin = 200, xmax = 145, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white", size = 1.5)+
    annotate("text", x = (200+145)/2, y = yrange[1]+0.5, label = "J", size = 8)+
    annotate("rect", xmin = 145, xmax = 66, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white", size = 1.5)+
    annotate("text", x = (145+66)/2, y = yrange[1]+0.5, label = "K", size = 8)+
    annotate("rect", xmin = 66, xmax= 23.03, ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "grey40")+
    annotate("rect", xmin = 66, xmax = 23.03, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white", size = 1.5)+
    annotate("text", x = (66+23.03)/2, y = yrange[1]+0.5, label = "Pg", size = 8)+
    annotate("rect", xmin = 23.03, xmax = 2.58, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white", size = 1.5)+
    annotate("text", x = (23.03+2.58)/2, y = yrange[1]+0.5, label = "Ng", size = 8)+
    annotate("rect", xmin = 2.58, xmax = -Inf, ymin = -Inf, ymax = yrange[1]+3, alpha = 1, color = "black", fill = "white", size = 1.5)
  
  return(northern_border)
  
}


## EXECUTION --------------------------------------------------------------------------------------------------------

cor_bor <- make_plots("Corals")
cro_bor <- make_plots("Crocos")

arr1 <- ggarrange(cor_bor, cro_bor, nrow = 2, ncol = 1, labels = "AUTO", font.label = list(size = 30))
ggsave(filename = "./figures/case_study/subtrop_bound_estim_2taxa.png", plot = arr1, device = "png", width = 350, height = 350, unit = "mm")
