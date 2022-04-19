################## This script quantifies the relation between plate area and lat sd ##################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


library(ggplot2)

## function to assess confidence interval at 95% -------------------------------
IC_95 <- function(std, n){ #function to calculate confidence interval at a 95% confidence level (n big => t_95 = 1.96)
  return(1.96*std/sqrt(n))
}

## data ------------------------------------------------------------------------
store <- readRDS("./data/plate_areas/cross_categorisation.RDS") #plates cross cat
latsd <- readRDS("./data/standard_deviation_4mdls.RDS")[-MAX,] #lat standard deviation over space and time

## implementation --------------------------------------------------------------

final <- data.frame(TIME = rep(0, length(unique(store$cross_cat))),
                    AVERAGE_LATSD = rep(0, length(unique(store$cross_cat))),
                    CAT = c("cc=4", "cc=5", "cc=6", "cc=7", "cc=8", "cc=9"),
                    CI_95 = rep(0, length(unique(store$cross_cat))))

for(Time in seq(from = 50, to = 500, by = 50)){
  av_sd <- c()
  ci <- c()
  for(i in seq(from = 4, to = 9, by = 1)){
    COL = paste0("lat_", Time)
    index_cells <- which(store$cross_cat == i)
    av_sd <- c(av_sd, mean(latsd[index_cells, c(COL)], na.rm = T))
    ci <- c(ci, IC_95(std = sd(latsd[index_cells, c(COL)], na.rm = T),
                               n = length(index_cells)))
  }
  final <- rbind(final, data.frame(TIME = rep(Time, length(unique(store$cross_cat))),
                                   AVERAGE_LATSD = av_sd,
                                   CAT = c("cc=4", "cc=5", "cc=6", "cc=7", "cc=8", "cc=9"),
                                   CI_95 = ci))
}




bplt <- ggplot(data = final, aes(x = TIME, y = AVERAGE_LATSD, fill = CAT, width = 35)) +
  geom_bar(stat = "identity", color = "black", position = position_dodge()) +
  geom_errorbar(aes(ymin = AVERAGE_LATSD - CI_95, ymax = AVERAGE_LATSD + CI_95),
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
  labs(x = "Time (Ma)", y = "Latitudinal standard deviation (°)", fill = "Cross_category") +
  geom_vline(xintercept = 200, col = "red", linetype = "dashed") +
  geom_vline(xintercept = 410, col = "red", linetype = "dashed") +
  scale_fill_manual(values = c('#f7f7f7','#d9d9d9','#bdbdbd','#969696','#636363','#252525')) +
  scale_x_reverse()
  
bplt
