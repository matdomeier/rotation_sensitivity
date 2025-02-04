# ------------------------------------------------------------------------- #
# Purpose: Plot barplots
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(ggplot2)
library(ggpubr)
library(deeptime)
library(sf)
# palettes
pal1 <- c('#f7fcb9','#addd8e','#41ab5d','#006837','#004529')
pal2 <- c('#fde0dd','#fa9fb5','#dd3497','#7a0177','#49006a')
# Latitudinal standard deviation ------------------------------------------
# Load data and drop lng/lat column
df <- readRDS("./results/lat_SD_LF.RDS")
# Drop geometry
df <- sf::st_drop_geometry(df)
# Unique time intervals 
t <- unique(df$time)
# Set up count categories
lower <- c(0, 5, 10, 20, 30)
upper <- c(5, 10, 20, 30, 90)
cat <- c("0 \U2013 5", "5 \U2013 10", 
         "10 \U2013 20", "20 \U2013 30", "> 30")
# Set up counts df
counts_df <- data.frame(time = rep(t, each = 5),
                        lower = rep(lower, times = length(t)),
                        upper = rep(upper, times = length(t)),
                        cat = rep(cat, times = length(t)),
                        counts = rep(NA, times = length(t) * 5))
# Count 
for (i in t) {
  # Extract values for each time
  vals <- df[which(df$time == i), c("lat_sd")] 
  # How many NAs?
  n <- length(which(!is.na(vals)))
  # Count per category
  for (j in seq_along(lower)) {
    # Count per category and standardise by available cells
    counts <- length(which(vals >= lower[j] & vals < upper[j])) / n
    # Add counts to category
    counts_df$counts[which(counts_df$time == i & counts_df$lower == lower[j])] <- counts
  }
}

# Set factor levels
counts_df$cat <- factor(counts_df$cat, levels = c("0 \U2013 5", 
                                                  "5 \U2013 10", 
                                                  "10 \U2013 20",
                                                  "20 \U2013 30",
                                                  "> 30"))

# Generate plot
p1 <- ggplot(data = counts_df, aes(x = time, y = counts, fill = cat)) +
  geom_bar(position = "stack", stat = "identity") +
  geom_vline(xintercept = 410) + 
  geom_text(aes(x = 415, y = 0.9, label = "MA16", angle = 90), size = 4.5) +
  scale_fill_manual(values = pal1) +
  scale_x_reverse(limits = c(545, -5),
                  breaks = seq(0, 540, 50),
                  labels = seq(0, 540, 50)) + 
  scale_y_continuous(limits = c(0, 1.001), 
                     breaks = seq(from = 0, to = 1, by = 0.2), 
                     labels = seq(from = 0, to = 1, by = 0.2)) +
  labs(x = "Time (Ma)",
       y = "Cell proportion",
       fill = "Palaeolatitudinal standard deviation (\u00B0)") +
  theme(plot.margin = margin(5, 10, 5, 10, "mm"),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        axis.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12),
        legend.key.size = unit(1, "cm"),
        legend.position = "top",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 1))
# Add geological timescale
p1 <- p1 + coord_geo(pos = "bottom", xlim = c(545, 0), fill = "grey95", height = unit(1.5, "line"))
p1
# Normalised geodesic distance --------------------------------------------
# Load data and drop lng/lat column
df <- readRDS("./results/GDD_LF.RDS")
# Drop geometry
df <- sf::st_drop_geometry(df)
# Unique time intervals 
t <- unique(df$time)
# Set up count categories
lower <- c(0, 1000, 2500, 5000, 8500)
upper <- c(1000, 2500, 5000, 8500, 14000)
cat <- c("0 \U2013 1000",
         "1000 \U2013 2500", 
         "2500 \U2013 5000",
         "5000 \U2013 8500",
         ">8500")
# Set up counts df
counts_df <- data.frame(time = rep(t, each = 5),
                        lower = rep(lower, times = length(t)),
                        upper = rep(upper, times = length(t)),
                        cat = rep(cat, times = length(t)),
                        counts = rep(NA, times = length(t) * 5))
# Count 
for (i in t) {
  # Extract values for each time
  vals <- df[which(df$time == i), c("Geodesic_dist")] 
  # How many NAs?
  n <- length(which(!is.na(vals)))
  # Count per category
  for (j in seq_along(lower)) {
    # Count per category and standardise by available cells
    counts <- length(which(vals >= lower[j] & vals < upper[j])) / n
    # Add counts to category
    counts_df$counts[which(counts_df$time == i & counts_df$lower == lower[j])] <- counts
  }
}

# Set factor levels
counts_df$cat <- factor(counts_df$cat, levels = c("0 \U2013 1000",
                                                  "1000 \U2013 2500", 
                                                  "2500 \U2013 5000",
                                                  "5000 \U2013 8500",
                                                  ">8500"))

# Generate plot
p2 <- ggplot(data = counts_df, aes(x = time, y = counts, fill = cat)) +
  geom_bar(position = "stack", stat = "identity") +
  geom_vline(xintercept = 410) + 
  geom_text(aes(x = 415, y = 0.9, label = "MA16", angle = 90), size = 4.5) +
  scale_fill_manual(values = pal2) +
  scale_x_reverse(limits = c(545, -5),
                  breaks = seq(0, 540, 50),
                  labels = seq(0, 540, 50)) + 
  scale_y_continuous(limits = c(0, 1.001), 
                     breaks = seq(from = 0, to = 1, by = 0.2), 
                     labels = seq(from = 0, to = 1, by = 0.2)) +
  labs(x = "Time (Ma)",
       y = "Cell proportion",
       fill = "Normalised Geodesic distance (km)") +
  theme(plot.margin = margin(5, 10, 5, 10, "mm"),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        axis.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12),
        legend.key.size = unit(1, "cm"),
        legend.position = "top",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 1))
# Add geological timescale
p2 <- p2 + coord_geo(pos = "bottom", xlim = c(545, 0), fill = "grey95", height = unit(1.5, "line"))
# Combine plots -----------------------------------------------------------
# Arrange plot
p <- ggarrange(p1, p2, ncol = 1, nrow = 2, labels = c("(a)", "(b)"),
               font.label = list(size = 20))
# Save plot
ggsave(filename = "./figures/cell_proportions.png",
       height = 280,
       width = 260,
       units = "mm",
       dpi = 600)

