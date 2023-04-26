# ------------------------------------------------------------------------- #
# Purpose: Plot latitudinal standard deviation maps
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(sf)
library(ggplot2)
# palette
pal <- c('#fde0dd','#fa9fb5','#dd3497','#7a0177','#49006a', 'black')
# -------------------------------------------------------------------------
# Load data
df <- readRDS("./results/GDD_LF.RDS")
# Print summary of uncertainty
cenozoic <- df[which(df$time <= 66), ]
print(paste0(length(which(cenozoic$Geodesic_dist > 1000))/nrow(cenozoic)*100, "% of cells have a value more than 1000"))
mesozoic <- df[which(df$time > 66 & df$time <= 252), ]
print(paste0(length(which(mesozoic$Geodesic_dist > 1000))/nrow(mesozoic)*100, "% of cells have a value more than 1000"))
palaeozoic <- df[which(df$time > 252), ]
print(paste0(length(which(palaeozoic$Geodesic_dist > 1000))/nrow(palaeozoic)*100, "% of cells have a value more than 1000"))
cambrian <- df[which(df$time > 485), ]
print(paste0(length(which(cambrian$Geodesic_dist > 5000))/nrow(cambrian)*100, "% of cells have a value more than 5000"))
# Ages to plot
ages <- c(60, 120, 180, 240, 300, 360, 420, 480, 540)
# Subset df
df <- df[which(df$time %in% ages), ]
df$time_lab <- paste0(df$time, " Ma")
# Set factor levels
df$time_lab <- factor(df$time_lab, levels = c("60 Ma", "120 Ma", "180 Ma",
                                              "240 Ma", "300 Ma", "360 Ma",
                                              "420 Ma", "480 Ma", "540 Ma"))


# Create facet plot
p <-  ggplot(data = df, aes(fill = Geodesic_dist)) +
  scale_fill_stepsn(colours = pal,
                    limits = c(0, 14000),
                    breaks = c(0, 1000, 2500, 5000, 8500, 14000)) +
  geom_sf(colour = NA, size = 0.1) +
  labs(fill = "Normalised geodesic distance (km)") +
  theme_minimal() +
  theme(
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    strip.text = element_text(size = 16),
    plot.background = element_rect(fill = "white", colour = NA),
    plot.title = element_text(hjust = 0.5),
    axis.text = element_blank(),
    legend.position = "bottom") +
  guides(fill = guide_colourbar(barheight = unit(8, "mm"),
                                barwidth = unit(120, "mm"),
                                frame.colour = "black",
                                ticks.colour = "black", 
                                ticks.linewidth = 1,
                                title.hjust = 0.5,
                                title.position = "bottom")) +
  facet_wrap(~ time_lab, nrow = 3, ncol = 3)

ggsave(filename = paste0("./figures/GDD/temporal_snap.png"),
       plot = p,
       height = 280,
       width = 400,
       units = "mm",
       dpi = 300)
