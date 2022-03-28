############### This script estimates and plots the evolution of the MST length according to the different ID_scores zones ################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


## Import libraries --------------------------------------------------------------------------------------

library(ggplot2)
library(latex2exp)


## Input dataset and function for CI_95 ------------------------------------------------------------------

ID_score <- readRDS("./data/data_pts_plate_IDs_according_to_the_four_models.RDS") #ID_score
IC_95 <- function(std, n){ #function to caculate confidence interval at a 95% confidence level (n big => t_95 = 1.96)
  return(1.96*std/sqrt(n))
}

index_IDsc1 <- which(ID_score$ID_score == 1) #as the cells of METRIC and ID_score are ordered in the same way, we can directly use these lists
index_IDsc2 <- which(ID_score$ID_score == 2)
index_IDsc3 <- which(ID_score$ID_score == 3)


## Loop for both metrics (lat sd and MST length) ---------------------------------------------------------
for(metric in c("sd", "MST")){
  if(metric == "sd"){
    METRIC <- readRDS("./data/standard_deviation_4mdls.RDS")
    METRIC <- METRIC[-MAX, -c(1:2, seq(from = 3, to = ncol(METRIC), by = 2))]
    ylab <- "Latitudinal Standard Deviation (°)"
    y_ann <- 20
    filename <- "./figures/Lat_sd_IDsc_barplot.png"
  }
  else if(metric == "MST"){
    METRIC <- readRDS("./data/MST_length.RDS")[,-c(1:2)]
    ylab <- TeX("Average MST length (x $10^3$ km)")
    y_ann <- 8.5
    filename <- "./figures/MST_IDsc_barplot.png"
  }
  
  # Assess and store average metric and IC 95 ------------------------------------------------------------
  
  final <- data.frame(TIME = c(0,0,0),
                      AVERAGE_METRIC = c(0,0,0),
                      ID_w = c("ID_score = 1", "ID_score = 2", "ID_score = 3"),
                      CI_95 = c(0,0,0))
  
  for(t in seq(from = 50, to = 500, by = 50)){ #timestep of 50My to avoid too heavy plots
    
    av_1 <- mean(METRIC[index_IDsc1, t/10], na.rm = TRUE)
    IC_1 <- IC_95(std = sd(METRIC[index_IDsc1, t/10], na.rm = TRUE), 
                  n = length(na.omit(METRIC[index_IDsc1, t/10])))
    
    av_2 <- mean(METRIC[index_IDsc2, t/10], na.rm = TRUE)
    IC_2 <- IC_95(std = sd(METRIC[index_IDsc2, t/10], na.rm = TRUE), 
                  n = length(na.omit(METRIC[index_IDsc2, t/10])))
    
    av_3 <- mean(METRIC[index_IDsc3, t/10], na.rm = TRUE)
    IC_3 <- IC_95(std = sd(METRIC[index_IDsc3, t/10], na.rm = TRUE), 
                  n = length(na.omit(METRIC[index_IDsc3, t/10])))
    
    final <- rbind(final,
                   final <- data.frame(TIME = c(t,t,t),
                                       AVERAGE_METRIC = c(av_1, av_2, av_3),
                                       ID_w = c("ID_score = 1", "ID_score = 2", "ID_score = 3"),
                                       CI_95 = c(IC_1, IC_3, IC_3)))
  }
  
  
  # Plot it --------------------------------------------------------------------------------------------
  
  bplt <- ggplot(data = final, aes(x = TIME, y = AVERAGE_METRIC, fill = ID_w, width = 35)) +
    geom_bar(stat = "identity", color = "black", position = position_dodge()) +
    geom_errorbar(aes(ymin = AVERAGE_METRIC - CI_95, ymax = AVERAGE_METRIC + CI_95),
                  width = 11, 
                  position=position_dodge(35)) +
    theme(axis.title.x = element_text(size = 18),
          axis.title.y = element_text(size = 18),
          axis.text = element_text(size = 15),
          legend.text = element_text(size = 15),
          legend.key.size = unit(0.5, "cm"),
          panel.border = element_blank(), # Remove panel border
          panel.grid.major = element_blank(), # Remove panel grid lines
          panel.grid.minor = element_blank(), 
          panel.background = element_blank(), # Remove panel background
          axis.line = element_line(colour = "black", size = 1, linetype = "solid"),
    ) +
    labs(x = "Time (Ma)", y = ylab, fill = "") +
    geom_vline(xintercept = 200, col = "red", linetype = "dashed") +
    geom_vline(xintercept = 410, col = "red", linetype = "dashed") +
    scale_fill_manual(values = c("#fee0d2", "#fc9272", "#ef3b2c")) +
    scale_x_reverse() +
    annotate(geom = "text", x = 210, y = y_ann, label = "Seton Time Limit", angle = 90, size = 4, fontface = "italic", col = "red") +
    annotate(geom = "text", x = 420, y = y_ann, label = "Matthews Time Limit", angle = 90, size = 4, fontface = "italic", col = "red")
  
  ggsave(filename = filename, plot = bplt, height = 8, width = 15)
  
  
  # Wilcoxon's test -------------------------------------------------------------------------------------
  
  #we are going to compute wilcox tets (non-parametric as normality assumption not filled) testing the differences globalxID_scores1 and GlobalxID_scores3
  #the p-values are going to be summarised in a table
  
  w_table <- data.frame(IDsc1xIDsc2 = rep(0, 10), 
                        IDsc1xIDsc3 = rep(0, 10), 
                        IDsc2xIDsc3 = rep(0, 10))
  
  for(t in seq(from = 50, to = 500, by = 50)){
    w_table$IDsc1xIDsc2[[t/50]] <- wilcox.test(x = na.omit(METRIC[index_IDsc1, t/10]), y = na.omit(METRIC[index_IDsc2, t/10]))$p.value #1x2
    w_table$IDsc1xIDsc3[[t/50]] <- wilcox.test(x = na.omit(METRIC[index_IDsc1, t/10]), y = na.omit(METRIC[index_IDsc3, t/10]))$p.value #1x3
    w_table$IDsc2xIDsc3[[t/50]] <- wilcox.test(x = na.omit(METRIC[index_IDsc2, t/10]), y = na.omit(METRIC[index_IDsc3, t/10]))$p.value #2x3
  }
  
  ind = which(w_table > 0.05)
  print(ind) # For MST, displays 9. On the 9th line, the only value above 0.05 arises when we compare zones of ID_sc = 1 and 2.. why not. For Latsd, everything is significant
  
  
}
