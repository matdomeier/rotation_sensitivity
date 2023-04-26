# ------------------------------------------------------------------------- #
# Purpose: Plot Cambrian polygon maps
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(ggplot2)
library(ggpubr)
library(sf)
library(raster)
# Load --------------------------------------------------------------------
# Set up bounding box
ras <- raster::raster(res = 5, val = 1)
ras <- rasterToPolygons(x = ras, dissolve = TRUE)
# Robinson projection
bb <- sf::st_as_sf(x = ras)
bb <- st_transform(x = bb, crs = "ESRI:54030")
# PALEOMAP
paleomap_500 <- sf::read_sf("https://gws.gplates.org/reconstruct/static_polygons/?&time=500&model=PALEOMAP")
paleomap_540 <- sf::read_sf("https://gws.gplates.org/reconstruct/static_polygons/?&time=540&model=PALEOMAP")
# GOLONKA 
golonka_500 <- sf::read_sf("https://gws.gplates.org/reconstruct/static_polygons/?&time=500&model=GOLONKA")
golonka_540 <- sf::read_sf("https://gws.gplates.org/reconstruct/static_polygons/?&time=540&model=GOLONKA")
# MERDITH 2021
merdith_500 <- sf::read_sf("https://gws.gplates.org/reconstruct/static_polygons/?&time=500&model=MERDITH2021")
merdith_540 <- sf::read_sf("https://gws.gplates.org/reconstruct/static_polygons/?&time=540&model=MERDITH2021")

# Plot --------------------------------------------------------------------
# Plot function
plot_map <- function(x, main, bb){
  ggplot(x) + 
    geom_sf(data = bb, fill = "lightblue", col = NA) +
    geom_sf(size = 0.1) +
    labs(title = main) +
    theme_void() +
    theme(
      plot.margin = margin(5, 5, 5, 5, "mm"),
      axis.text = element_blank(),
      plot.title = element_text(hjust = 0.5)) +
    coord_sf(crs = sf::st_crs("ESRI:54030"))
}
# Create plots
# 500 Ma
p1 <- plot_map(golonka_500, main = "500 Ma - Wright et al. (2013)", bb = bb)
p2 <- plot_map(paleomap_500, main = "500 Ma - Scotese & Wright (2018)", bb = bb)
p3 <- plot_map(merdith_500, main = "500 Ma - Merdith et al. (2021)", bb = bb)
# 540 Ma
p4 <- plot_map(golonka_540, main = "540 Ma - Wright et al. (2013)", bb = bb)
p5 <- plot_map(paleomap_540, main = "540 Ma - Scotese & Wright (2018)", bb = bb)
p6 <- plot_map(merdith_540, main = "540 Ma - Merdith et al. (2021)", bb = bb)

# Combine plots -----------------------------------------------------------
# Arrange plot
p <- ggarrange(p1, p4, p2, p5, p3, p6, ncol = 2, nrow = 3,
               labels = c("(a)", "(b)", "(c)", "(d)", "(e)", "(f)"),
               font.label = list(size = 18), align = "hv")
# Save plot
ggsave(filename = "./figures/cambrian_continental_polygons.png",
       height = 250,
       width = 250,
       units = "mm",
       bg = "white",
       dpi = 600)
