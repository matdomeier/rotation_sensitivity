# ------------------------------------------------------------------------- #
# Purpose: Plot MST length
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# WARNING: This script can take a while to run depending on the user's PC.
# If you wish to test the script, you can reduce the sequence in line 36.
# Load libraries ----------------------------------------------------------
library(dggridR)
library(sf)
library(ggplot2)
library(gganimate)
library(transformr)
library(gifski)
library(himach)
pal <- c('#fde0dd','#fa9fb5','#dd3497','#7a0177','#49006a', 'black')
# -------------------------------------------------------------------------
# Load data
mst_length <- readRDS("./results/MST_length.RDS")
# Set up 0 column for plotting
mst_length$MST_length_0 <- 0

# Global initial grid
init_grid <- dgconstruct(spacing = 150)

# Overlay cells of lat_sd df with cells of the initial grid
mst_length$seqnum <- dgGEO_to_SEQNUM(dggs = init_grid,
                                 in_lon_deg = mst_length$lng,
                                 in_lat_deg = mst_length$lat)$seqnum

# Build a grid with cells only containing a MST length value --------------
grid <- dgcellstogrid(dggs = init_grid, cells = mst_length$seqnum)

# Loop to plot MST length over time out of this grid ----------------------
# Create empty df
df <- data.frame()
for (t in seq(from = 0, to = 540, by = 10)) {
  # Column name in MST length dataset
  col <- paste0("MST_length_", t)
  # Merge with the lat sd values at t
  grid1 <- merge(grid, mst_length[,c("seqnum", col)], by = c("seqnum"))
  # Transform to Robinson projection and fix cells crossing dateline
  trans_grid <- himach::st_window(m = grid1, crs = crs_Atlantic)
  # Transform to sf for binding
  trans_grid <- sf::st_as_sf(trans_grid)
  # Drop old geometry
  grid1 <- sf::st_drop_geometry(grid1)
  grid1 <- cbind(trans_grid, grid1)
  
  # Update column name for binding 
  colnames(grid1)[2] <- "MST_length"
  grid1$time <- t
  
  # Create individual time shot plot
  p <-  ggplot(data = grid1, aes(fill = MST_length)) +
    scale_fill_stepsn(colours = pal,
                      limits = c(0, 25000),
                      breaks = c(0, 3000, 6000, 9000, 12000, 25000)) +
    geom_sf(colour = NA, size = 0.1) +
    labs(title = paste0("Time step: ", t,
                        " Ma"),
         fill = "Minimum-spanning-tree length (km)") +
    theme_minimal() +
    theme(
      plot.background = element_rect(fill = "white", colour = NA),
      plot.title = element_text(hjust = 0.5),
      legend.position = "bottom") +
    guides(fill = guide_colourbar(barheight = unit(8, "mm"),
                                  barwidth = unit(120, "mm"),
                                  frame.colour = "black",
                                  ticks.colour = "black", 
                                  ticks.linewidth = 1,
                                  title.theme = element_text(colour = "black"),
                                  title.hjust = 0.5,
                                  title.position = "bottom"))
  # Save individual time shot
  ggsave(filename = paste0("./figures/MST/time_step_", t, ".png"),
         plot = p,
         height = 150,
         width = 280,
         units = "mm",
         dpi = 300)
  
  # Create long format df for GIF
  df <- rbind.data.frame(df, grid1)
}
# Save long format dataframe
saveRDS(df, "./results/MST_length_LF.RDS")

# Create initial plot for GIF 
p <-  ggplot(data = df, aes(fill = MST_length)) +
  scale_fill_stepsn(colours = pal,
                    limits = c(0, 20000),
                    breaks = c(0, 3000, 6000, 9000, 12000, 20000)) +
  geom_sf(colour = "black", size = 0.1) +
  labs(title = paste0("Time step: {as.integer(unique(df$time)[frame])}",
                      " Ma"),
       fill = "Minimum-spanning-tree length (km)") +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "white", colour = NA),
    plot.title = element_text(hjust = 0.5),
    legend.position = "bottom") +
  guides(fill = guide_colourbar(barheight = unit(8, "mm"),
                                barwidth = unit(120, "mm"),
                                frame.colour = "black",
                                ticks.colour = "black", 
                                ticks.linewidth = 1,
                                title.theme = element_text(colour = "black"),
                                title.hjust = 0.5,
                                title.position = "bottom"))
# Add manual transition over time
p <- p + transition_manual(frames = time)

# Animate the plot as a GIF
animate(plot = p,
        fps = 2,
        duration = 27,
        renderer = gifski_renderer(loop = T),
        height = 150,
        width = 300,
        units = "mm",
        res = 300)

# Save animation
anim_save("./figures/MST/time_series.gif")

