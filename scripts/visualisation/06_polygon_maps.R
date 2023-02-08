# ------------------------------------------------------------------------- #
# Purpose: Plot continental polygon maps
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(ggplot2)
library(ggpubr)
library(raster)
library(sf)
# Load --------------------------------------------------------------------
# Set up bounding box
ras <- raster::raster(res = 5, val = 1)
ras <- rasterToPolygons(x = ras, dissolve = TRUE)
# Robinson projection
bb <- sf::st_as_sf(x = ras)
bb <- st_transform(x = bb, crs = "ESRI:54030")

# Load polygons and project to robinson
# Golonka polygons
golonka <- read_sf("./data/continental_polygons/GOLONKA/GOLONKA_PresentDay_ContinentalPolygons.shp")

# Scotese polygons
paleomap <- read_sf("./data/continental_polygons/PALEOMAP/PALEOMAP_PresentDay_ContinentalPolygons.shp")

# Matthews polygons
matthews <- read_sf("./data/continental_polygons/MATTHEWS2016_pmag_ref/MATTHEWS2016_pmag_ref_PresentDay_ContinentalPolygons.shp")

# Seton polygons
seton <- read_sf("./data/continental_polygons/SETON2012/SETON2012_PresentDay_ContinentalPolygons.shp")

# Muller polygons
muller <- read_sf("./data/continental_polygons/MULLER2016/MULLER2016_PresentDay_ContinentalPolygons.shp")

# Merdith polygons
merdith <- read_sf("./data/continental_polygons/MERDITH2021/MERDITH2021_PresentDay_ContinentalPolygons.shp")

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
p1 <- plot_map(seton, main = "Seton et al. (2012)", bb = bb)
p2 <- plot_map(golonka, main = "Wright et al. (2013)", bb = bb)
p3 <- plot_map(matthews, main = "Matthews et al. (2016)", bb = bb)
p4 <- plot_map(muller, main = "M\U00FCller et al. (2016)", bb = bb)
p5 <- plot_map(paleomap, main = "Scotese & Wright (2018)", bb = bb)
p6 <- plot_map(merdith, main = "Merdith et al. (2021)", bb = bb)

# Combine plots -----------------------------------------------------------
# Arrange plot
p <- ggarrange(p1, p2, p3, p4, p5, p6, ncol = 2, nrow = 3,
               labels = c("(a)", "(b)", "(c)", "(d)", "(e)", "(f)"),
               font.label = list(size = 18))
# Save plot
ggsave(filename = "./figures/continental_polygons.png",
       height = 250,
       width = 250,
       units = "mm",
       bg = "white",
       dpi = 600)
