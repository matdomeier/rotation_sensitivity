# ------------------------------------------------------------------------- #
# Purpose: Plot fossil palaeolat range
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(ggplot2)
library(matrixStats)
# Corals -----------------------------------------------------------------
# List files
files <- list.files("./data/fossil_palaeocoordinates/corals/", full.names = TRUE)
# Coral Reefs
df <- data.frame(time = readRDS(files[1])$mid_ma,
                 min = NA,
                 median = NA,
                 max = NA)

for (i in files) {
  palaeolat <- readRDS(i)[, c("palaeolat")]
  df <- cbind.data.frame(df, palaeolat)
}

# Get stats
df$min <- rowMins(as.matrix.data.frame(df[5:10]), na.rm = TRUE)
df$median <- rowMedians(as.matrix.data.frame(df[5:10]), na.rm = TRUE)
df$max <- rowMaxs(as.matrix.data.frame(df[5:10]), na.rm = TRUE)

# Remove Inf data for plotting
df <- df[-which(is.infinite(df$max) == TRUE), ]

# Plot
p1 <- ggplot(data = df[, 1:4], aes(x = time, y = median)) +
  geom_errorbar(aes(ymin = min, ymax = max), colour = "#006837") +
  geom_point(shape = 21, size = 2.5, colour = "black", fill = "#006837", alpha = 0.7) +
  scale_y_continuous(limits = c(-90, 90),
                     labels = seq(-90, 90, 30),
                     breaks = seq(-90, 90, 30)) + 
  scale_x_reverse(limits = c(200, 0)) +
  labs(title = "Coral Reefs",
       x = "Time (Ma)",
       y = "Palaeolatitude (\u00B0)") +
  theme(plot.margin = margin(5, 10, 5, 10, "mm"),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        axis.text = element_text(size = 12),
        legend.background = element_blank(),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10),
        legend.key.size = unit(0.5, "cm"),
        legend.position = c(0.93, 0.15),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA, size = 0.5)) +
  deeptime::coord_geo(pos = "bottom", fill = "grey95", height = unit(1.5, "line"))

# Crocs ------------------------------------------------------------------
# List files
files <- list.files("./data/fossil_palaeocoordinates/crocs/", full.names = TRUE)
# Crocs
df <- data.frame(time = readRDS(files[1])$mid_ma,
                 min = NA,
                 median = NA,
                 max = NA)

for (i in files) {
  palaeolat <- readRDS(i)[, c("palaeolat")]
  df <- cbind.data.frame(df, palaeolat)
}

# Get stats
df$min <- rowMins(as.matrix.data.frame(df[5:10]), na.rm = TRUE)
df$median <- rowMedians(as.matrix.data.frame(df[5:10]), na.rm = TRUE)
df$max <- rowMaxs(as.matrix.data.frame(df[5:10]), na.rm = TRUE)

# Plot
p2 <- ggplot(data = df[, 1:4], aes(x = time, y = median)) +
  geom_errorbar(aes(ymin = min, ymax = max), colour = "#7a0177") +
  geom_point(shape = 21, size = 2.5, colour = "black", fill = "#7a0177", alpha = 0.7) +
  scale_y_continuous(limits = c(-90, 90),
                     labels = seq(-90, 90, 30),
                     breaks = seq(-90, 90, 30)) + 
  scale_x_reverse(limits = c(200, 0)) +
  labs(title = "Crocodylomorphs",
       x = "Time (Ma)",
       y = "Palaeolatitude (\u00B0)") +
  theme(plot.margin = margin(5, 10, 5, 10, "mm"),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        axis.text = element_text(size = 12),
        legend.background = element_blank(),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10),
        legend.key.size = unit(0.5, "cm"),
        legend.position = c(0.93, 0.15),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA, size = 0.5)) +
  deeptime::coord_geo(pos = "bottom", fill = "grey95", height = unit(1.5, "line"))

# Combine plots -----------------------------------------------------------
# Arrange plot
p <- ggarrange(p1, p2, ncol = 1, nrow = 2, labels = "AUTO",
               font.label = list(size = 20))
# Save plot
ggsave(filename = "./figures/lat_range.png",
       height = 250,
       width = 210,
       units = "mm",
       dpi = 600)
