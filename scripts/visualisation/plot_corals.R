############## This script plots the corals reconstructed palaeocoordinates according to the 4 different modelsc ##################

library(ggplot2)

palette <- c("#33a02c", "#fb9a99", "#e31a1c", "#fdbf6f")
models <- c("Golonka", "Seton", "Matthews", "Scotese")


TIME <- c()
MAXI <- c() #these vectors will contain the max and min of the reconstructed latitudes according to the model => extent of intertropical belt
MINI <- c()
GROUP <- c()

for(mdl in models){
  print(mdl)
  data <- readRDS(paste0("./data/fossil_extracted_paleocoordinates/Corals/", mdl, ".RDS"))
  TIME <- c(TIME, sort(unique(data$TB)))
  GROUP <- c(GROUP, rep(mdl, length(sort(unique(data$TB)))))
  for(t in sort(unique(data$TB))){
    COL <- paste0("lat_", t)
    print(COL)
    indexes <- which(is.na(data[, c(COL)]) == FALSE)
    lat <- data[indexes, c(COL)]
    MAXI <- c(MAXI, max(lat))
    MINI <- c(MINI, min(lat))
  }
}

length(TIME)
length(MAXI)
length(GROUP)

to_plot <- data.frame(TIME = TIME,
                      lat_max = MAXI,
                      lat_min = MINI,
                      GROUP = GROUP)

to_plot$lat_max[which(to_plot$lat_max == -Inf)] = NA
to_plot$lat_max[which(to_plot$lat_min == -Inf)] = NA
  
ggplot(data = to_plot, aes(x = TIME, y = lat_max, group = GROUP, color = factor(GROUP))) +
  geom_point() +
  scale_x_reverse(breaks = seq(from = 0, to = 235, by = 47)) +
  ylim(0,55) +
  scale_colour_manual(values = palette, name = "Model") +    
  geom_line(lwd = 1) +
  theme(text = element_text(size = 25),
        axis.line = element_line(colour = "black", size = 1, linetype = "solid"),
        axis.text.x = element_text(size = 23),
        axis.text.y = element_text(size = 23),
        panel.grid.major = element_blank(), # Remove panel grid lines
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(), # Remove panel background
        panel.border = element_rect(colour = "black", fill = NA, size = 1)) + #frame the plot
  labs(x = "Time (Ma)", y = "Latitude (°)")
