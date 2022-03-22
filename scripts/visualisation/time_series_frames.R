################# This script plot and saves the lat sd time series of the red frames ################


#Author: Lucas Buffan
#Copyright (c) Lucas Buffan 2022
#e-mail: lucas.l.buffan@gmail.com


library(ggplot2)

#CARRIBEAN FRAME
FRAME1 <- list("lon_w" = -103, #longitude of the most eastern corner (in degrees)
               "lon_e" = -53,  #longitude of the most western corner
               "lat_n" = 32,   #latitude of the most northern corner
               "lat_s" = 5)    #latitude of the most southern corner

#INDIAN FRAME
FRAME2 <- list("lon_w" = 54,
               "lon_e" = 98,
               "lat_n" = 38,
               "lat_s" = 15)

#OCEANIAN FRAME
FRAME3 <- list("lon_w" = 112,
               "lon_e" = 137,
               "lat_n" = 23,
               "lat_s" = -13)

TIMESCALE <- seq(from = 0, to = 200, by = 10)

FRAMES <- list(FRAME1, FRAME2, FRAME3)
SD <- readRDS("./data/standard_deviation_4mdls.RDS")[, -seq(from = 43, to = 110, by = 1)] #we only keep the first 200Myrs

for(i in 1:length(FRAMES)){
  frame = FRAMES[[i]]
  to_keep <- which((SD$lon_0 %in% seq(from = frame[["lon_w"]], to = frame[["lon_e"]], by = 0.5))
                   & 
                     (SD$lat_0 %in% seq(from = frame[["lat_s"]], to = frame[["lat_n"]], by = 0.5))) #target the cells in the frame
  SD_remain <- SD[to_keep, -c(which(seq(from = 1, to = ncol(SD)+1, by = 1) %%2 != 0))] #only keep latitudes (even col indexes) for the selected cells (row indexes in to_keep)
  SD_remain$lat_0 <- 0 #we set to 0 the lat sd at t = 0, which is normal
  
  AVERAGE <- lapply(X = SD_remain, FUN = mean, na.rm = TRUE) #average over space
  ET <- lapply(X = SD_remain, FUN = sd, na.rm = TRUE) #standard deviation (of averaged standard deviations... (yes, it's tricky) 
  
  avet <- data.frame(Time = TIMESCALE,
                     Av = as.numeric(AVERAGE), #we invert to plot it in a proper geological way
                     std = as.numeric(ET))
  
  ts_plot <- ggplot(data = avet, aes(x = Time, y = Av, ymin = Av-std, ymax = Av+std))+
    scale_x_reverse(breaks = seq(from = 0, to = 200, by = 50))+
    scale_y_continuous(expand = c(0,0), limits = c(-8, 30)) + #although no values <0, he confidence interval can be "theoretically" negative, hence the -8
    geom_line(lwd = 2, colour = '#006837')+
    geom_smooth(stat = "identity")+
    theme(text = element_text(size = 25),
          axis.line = element_line(colour = "black", size = 1, linetype = "solid"),
          axis.text.x = element_text(size = 23),
          axis.text.y = element_text(size = 23),
          panel.grid.major = element_blank(), # Remove panel grid lines
          panel.grid.minor = element_blank(), 
          panel.background = element_blank(), # Remove panel background
          panel.border = element_rect(colour = "black", fill = NA, size = 1)) + #frame the plot
    labs(x = "Time (Ma)", y= "Averaged Latitude SD (°)")
  
  ggsave(filename = paste0("./figures/time_series/FRAME_", i, ".pdf" ),
         plot = ts_plot,
         width = 10,
         height = 6)
}



i = 1
frame = FRAMES[[i]]
to_keep <- which((SD$lon_0 %in% seq(from = frame[["lon_w"]], to = frame[["lon_e"]], by = 0.5))
                 & 
                   (SD$lat_0 %in% seq(from = frame[["lat_s"]], to = frame[["lat_n"]], by = 0.5))) #target the cells in the frame
SD_remain <- SD[to_keep, -c(which(seq(from = 1, to = ncol(SD)+1, by = 1) %%2 != 0))] #only keep latitudes (even col indexes) for the selected cells (row indexes in to_keep)
SD_remain$lat_0 <- 0 #we set to 0 the lat sd at t = 0, which is normal

AVERAGE <- lapply(X = SD_remain, FUN = mean, na.rm = TRUE) #average over space
ET <- lapply(X = SD_remain, FUN = sd, na.rm = TRUE) #standard deviation (of averaged standard deviations... (yes, it's tricky) 

avet <- data.frame(Time = TIMESCALE,
                   Av = as.numeric(AVERAGE), #we invert to plot it in a proper geological way
                   std = as.numeric(ET))

ts_plot <- ggplot(data = avet, aes(x = Time, y = Av, ymin = Av-std, ymax = Av+std))+
  #scale_x_reverse(breaks = seq(from = 0, to = 200, by = 50))+
  #scale_y_continuous(expand = c(0,0), limits = c(-8, 30)) + #although no values <0, he confidence interval can be "theoretically" negative, hence the -8
  geom_line(lwd = 2, colour = '#006837')+
  geom_smooth(stat = "identity")+
  theme(text = element_text(size = 25),
        axis.line = element_line(colour = "black", size = 1, linetype = "solid"),
        axis.text.x = element_text(size = 23),
        axis.text.y = element_text(size = 23),
        panel.grid.major = element_blank(), # Remove panel grid lines
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(), # Remove panel background
        panel.border = element_rect(colour = "black", fill = NA, size = 1)) + #frame the plot
  labs(x = "Time (Ma)", y= "Averaged Latitude SD (°)")

ts_plot
