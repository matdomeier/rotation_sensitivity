############ This script draws the barplots illustrating the distribution of cells in the different categories of lat sd ##########


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## import our friend ggplot ------------------------------------------------------------------
library(ggplot2)


BaRploTs <- function(metric){
  
  ## Read sd results and get rid of longitude (odd indexes) ----------------------------------
  if(metric == "lat_standard_deviation"){
    metric_ds <- readRDS("./data/lat_standard_deviation_4mdls.RDS")[, -c(1)]
    metric_ds[, 1] <- 0 #we get rid of the two first columns (lon and lat of the cells) and set to 0 the col t = 0
    CAT <- c("A: 0-5°", "B: 5-10°", "C: 10-20°", "D: 20-30°", "E: >30°")
    CAT_values <- c(5,10,20,30)
    main <- "Latitudinal Standard Deviation"
    pal <- c('#f7fcb9','#addd8e','#41ab5d','#006837','#004529')
  }

  ## Or read MST length results -------------------------------------------------------------
  else if(metric == "MST_length"){
    metric_ds <- readRDS("./data/MST_length.RDS")[,-c(1,2)]
    CAT <- c("A: 0-3000 km", "B: 30-6000 km", "C: 60-9000 km", "D: 9-12000 km", "E: >12000 km")
    CAT_values <- c(3,6,9,12)
    main <- "MST Length"
    pal <- c('#fde0dd','#fa9fb5','#dd3497','#7a0177','#49006a')
  }
  
  ## Df for the barplot ----------------------------------------------------------------------
  final_df <- data.frame(TIME = rep(x = 0, 5),
                         CAT = CAT,
                         COUNTS = c(29500, 0, 0, 0, 0))
  
  for(t in seq(from = 10, to = 540, by = 10)){
    final_df <- rbind(final_df,
                      data.frame(TIME = rep(x = t, 5),
                                 CAT = CAT,  #the five categories we're considering
                                 COUNTS = c(
                                   length(which(metric_ds[, t/10] < CAT_values[[1]])),
                                   length(which((metric_ds[, t/10] < CAT_values[[2]]) & (metric_ds[, t/10] >= CAT_values[[1]]))), #translating these categories in terms of logical condition
                                   length(which((metric_ds[, t/10] < CAT_values[[3]]) & (metric_ds[, t/10] >= CAT_values[[2]]))),
                                   length(which((metric_ds[, t/10] < CAT_values[[4]]) & (metric_ds[, t/10] >= CAT_values[[3]]))),
                                   length(which(metric_ds[, t/10] >= CAT_values[[4]]))
                                 )
                      ))
  }
  
  ## Plotting ---------------------------------------------------------------------------------
  
  #raw counts
  barplt <- ggplot(data = final_df, aes(fill = CAT, x = TIME, y = COUNTS)) +
    geom_bar(position = "stack", #display counts
             stat = "identity") +
    scale_fill_manual(values = pal) +
    # scale_fill_viridis(discrete = T) +
    scale_x_reverse() +
    ggtitle(main) +
    theme(axis.title.x = element_text(size = 18),
          axis.title.y = element_text(size = 18),
          axis.text = element_text(size = 15),
          plot.title = element_text(size = 25),
          legend.title = element_text(size = 18),
          legend.text = element_text(size = 15),
          legend.key.size = unit(1, "cm"),
          panel.grid.major = element_blank(), # Remove panel grid lines
          panel.grid.minor = element_blank(), 
          panel.background = element_blank(), # Remove panel background
          panel.border = element_rect(colour = "black", fill = NA, size = 1) #frame the plot
    ) +
    labs(x = "Time (Ma)", y = "Cell count", fill = "Category") +
    geom_vline(xintercept = 200, col = "red", linetype = "dashed", lwd = 1) +
    geom_vline(xintercept = 410, col = "red", linetype = "dashed", lwd = 1) +
    annotate(geom = "text", x = 205, y = 28000, label = "Seton Time Limit", angle = 90, size = 3, fontface = "italic", col = "red") +
    annotate(geom = "text", x = 415, y = 28000, label = "Matthews Time Limit", angle = 90, size = 3, fontface = "italic", col = "red")
  
  ggsave(filename = paste0("./figures/barplots/", metric, "_barplot_counts.pdf"), plot = barplt, width = 14, height = 7, units = "in") #save as pdf
  ggsave(filename = paste0("./figures/barplots/", metric, "_barplot_counts.png"), plot = barplt, width = 14, height = 7, units = "in") #and png
  
  return()
}


## EXECUTE -------------------------------------------------------------------------------------

for(metric in c("lat_standard_deviation", "MST_length")){
  BaRploTs(metric)
}
