# ------------------------------------------------------------------------- #
# Purpose: Plot latitudinal standard deviation
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# WARNING: This script can take a while to run depending on the user's PC.
# If you wish to test the script, you can reduce the sequence in line 32.
# Load libraries ----------------------------------------------------------
library(dggridR)
library(sf)
library(ggplot2)
library(gganimate)
library(transformr)
library(gifski)
library(himach)
# palette
pal <- c('#f7fcb9','#addd8e','#41ab5d','#006837','#004529', 'black')
# -------------------------------------------------------------------------
# Load data
lat_sd <- readRDS("./results/lat_SD.RDS")

# Global initial grid
init_grid <- dgconstruct(spacing = 150)

# Overlay cells of lat_sd df with cells of the initial grid
lat_sd$seqnum <- dgGEO_to_SEQNUM(dggs = init_grid,
                                 in_lon_deg = lat_sd$lng,
                                 in_lat_deg = lat_sd$lat)$seqnum

# Build a grid with cells only containing a lat_sd value ------------------
grid <- dgcellstogrid(dggs = init_grid, cells = lat_sd$seqnum)

# Loop to plot lat sd over time out of this grid --------------------------
# Create empty df
df <- data.frame()
for (t in seq(from = 10, to = 540, by = 10)) {
  # Column name in lat_sd dataset
  col <- paste0("lat_", t) 
  
  # Merge with the lat sd values at t
  grid1 <- merge(grid, lat_sd[,c("seqnum", col)], by = c("seqnum"))
  # Transform to Robinson projection and fix cells crossing dateline
  trans_grid <- himach::st_window(m = grid1, crs = crs_Atlantic)
  # Transform to sf for binding
  trans_grid <- sf::st_as_sf(trans_grid)
  # Drop old geometry
  grid1 <- sf::st_drop_geometry(grid1)
  grid1 <- st_bind_cols(trans_grid, grid1)
  
  # Update column name for binding 
  colnames(grid1)[2] <- "lat_sd"
  grid1$time <- t
  
  # Create individual time shot plot
  p <-  ggplot(data = grid1, aes(fill = lat_sd)) +
    scale_fill_stepsn(colours = pal,
                      limits = c(0, 70),
                      breaks = c(0, 5, 10, 20, 30, 70)) +
    geom_sf(colour = "black", size = 0.1) +
    labs(title = paste0("Time step: ", t,
                        " Ma"),
         fill = "Latitudinal standard deviation (\u00B0)") +
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
  p
  # Save individual time shot
  ggsave(filename = paste0("./figures/standard_deviation/time_step_", t, ".png"),
         plot = p,
         height = 150,
         width = 280,
         units = "mm",
         dpi = 300)
  
  # Create long format df for GIF
  df <- rbind.data.frame(df, grid1)
}
# Save long format dataframe
saveRDS(df, "./results/lat_SD_LF.RDS")

# Create initial plot for GIF 
p <-  ggplot(data = df, aes(fill = lat_sd)) +
        scale_fill_stepsn(colours = pal,
                          limits = c(0, 70),
                          breaks = c(0, 5, 10, 20, 30, 70)) +
        geom_sf(colour = "black", size = 0.1) +
        labs(title = paste0("Time step: {as.integer(unique(df$time)[frame])}",
                            " Ma"),
             fill = "Latitudinal standard deviation (\u00B0)") +
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
anim_save("./figures/standard_deviation/time_series.gif")
