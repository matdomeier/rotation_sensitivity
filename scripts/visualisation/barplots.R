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
    brk <- c()
  }

  ## Or read MST length results -------------------------------------------------------------
  else if(metric == "MST_length"){
    metric_ds <- readRDS("./data/MST_length.RDS")[,-c(1,2)]
    CAT <- c("A: 0-3000 km", "B: 30-6000 km", "C: 60-9000 km", "D: 9-12000 km", "E: >12000 km")
    CAT_values <- c(3,6,9,12)
    main <- "MST Length"
    pal <- c('#fde0dd','#fa9fb5','#dd3497','#7a0177','#49006a')
    brk <- c(0, 200, 320, 400)
    
  }
  
  ## Df for the barplot ----------------------------------------------------------------------
  final_df <- data.frame(TIME = rep(x = 0, 5),
                         CAT = CAT,
                         COUNTS = c(25351, 0, 0, 0, 0))
  
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
  
  barplt <- ggplot(data = final_df, aes(fill = CAT, x = TIME, y = COUNTS)) +
    geom_bar(position = "stack", #display counts
             stat = "identity") +
    scale_fill_manual(values = pal) +
    # scale_fill_viridis(discrete = T) +
    scale_x_reverse(breaks = brk) +
    scale_y_continuous(limits = c(-1000, 26000), 
                       breaks = seq(from = 0, to = 25000, by = 5000), 
                       labels = seq(from = 0, to = 25000, by = 5000)) +
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
    #sub-periods delimitations
    annotate(geom = "text", x = 205, y = 23000, label = "Seton Time Limit", angle = 90, size = 3, fontface = "italic", col = "red") +
    annotate(geom = "text", x = 415, y = 23000, label = "Matthews Time Limit", angle = 90, size = 3, fontface = "italic", col = "red") +
    #geological timescale displaying
    annotate("rect", xmin = Inf, xmax = 485.8, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white") +
    annotate("text", x = (540+485.8)/2, y = -1000, label = "Cm", size = 7)+
    annotate("rect", xmin = 485.4, xmax = 443.8, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white") +
    annotate("text", x = (485.4+443.8)/2, y = -1000, label = "O", size = 7)+
    annotate("rect", xmin = 443.8, xmax = 419.2, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white") +
    annotate("text", x = (443.8+419.2)/2, y = -1000, label = "S", size = 7)+
    annotate("rect", xmin = 419.2, xmax = 358.9, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white") +
    annotate("text", x = (419.2+358.9)/2, y = -1000, label = "D", size = 7)+
    annotate("rect", xmin = 358.9, xmax = 298.9, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white") +
    annotate("text", x = (358.9+298.9)/2, y = -1000, label = "C", size = 7)+
    annotate("rect", xmin = 298.9, xmax = 251.9, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white") +
    annotate("text", x = (298.9+251.9)/2, y = -1000, label = "P", size = 7)+
    annotate("rect", xmin = 251.9, xmax = 201.3, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white") +
    annotate("text", x = (251.9+201.3)/2, y = -1000, label = "T", size = 7)+
    annotate("rect", xmin = 201.3, xmax = 145, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white") +
    annotate("text", x = (201.3+145)/2, y = -1000, label = "Ju", size = 7)+
    annotate("rect", xmin = 145, xmax = 66, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (145+66)/2, y = -1000, label = "Cr", size = 7)+
    annotate("rect", xmin = 66, xmax = 23.03, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (66+23.03)/2, y = -1000, label = "Pg", size = 7)+
    annotate("rect", xmin = 23.03, xmax = 2.58, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white")+
    annotate("text", x = (23.03+2.58)/2, y = -1000, label = "Ng", size = 7)+
    annotate("rect", xmin = 2.58, xmax = -Inf, ymin = -Inf, ymax = 0, alpha = 1, color = "black", fill = "white")
  
  
  ggsave(filename = paste0("./figures/barplots/", metric, "_barplot_counts.pdf"), plot = barplt, width = 14, height = 7, units = "in") #save as pdf
  ggsave(filename = paste0("./figures/barplots/", metric, "_barplot_counts.png"), plot = barplt, width = 14, height = 7, units = "in") #and png
  
  return()
}


## EXECUTE -------------------------------------------------------------------------------------

for(metric in c("lat_standard_deviation", "MST_length")){
  BaRploTs(metric)
}
