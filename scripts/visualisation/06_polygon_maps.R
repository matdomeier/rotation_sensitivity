# ------------------------------------------------------------------------- #
# Purpose: Plot continental polygon maps
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(ggplot2)
library(ggpubr)
library(sf)
# Load --------------------------------------------------------------------
# Load polygons and project to robinson

# Golonka polygons
golonka <- read_sf("./data/continental_polygons/GOLONKA/GOLONKA_PresentDay_ContinentalPolygons.shp")
# Robinson projection
golonka <- st_transform(x = golonka, crs = "ESRI:54030")

# Scotese polygons
paleomap <- read_sf("./data/continental_polygons/PALEOMAP/PALEOMAP_PresentDay_ContinentalPolygons.shp")
# Robinson projection
paleomap <- st_transform(x = paleomap, crs = "ESRI:54030")

# Matthews polygons
matthews <- read_sf("./data/continental_polygons/MATTHEWS2016_pmag_ref/MATTHEWS2016_pmag_ref_PresentDay_ContinentalPolygons.shp")
# Robinson projection
matthews <- st_transform(x = matthews, crs = "ESRI:54030")

# Seton polygons
seton <- read_sf("./data/continental_polygons/SETON2012/SETON2012_PresentDay_ContinentalPolygons.shp")
# Robinson projection
seton <- st_transform(x = seton, crs = "ESRI:54030")

# Muller polygons
muller <- read_sf("./data/continental_polygons/MULLER2019/MULLER2019_PresentDay_ContinentalPolygons.shp")
# Robinson projection
muller <- st_transform(x = muller, crs = "ESRI:54030")

# Merdith polygons
merdith <- read_sf("./data/continental_polygons/MERDITH2021/MERDITH2021_PresentDay_ContinentalPolygons.shp")
# Robinson projection
merdith <- st_transform(x = merdith, crs = "ESRI:54030")

# Plot --------------------------------------------------------------------
# Plot function
plot_map <- function(x, main){
  ggplot(x) + 
    geom_sf(size = 0.25) +
    labs(title = main) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5))
}
# Create plots
p1 <- plot_map(seton, main = "Seton et al. (2012)")
p2 <- plot_map(golonka, main = "Wright et al. (2013)")
p3 <- plot_map(matthews, main = "Matthews et al. (2016)")
p4 <- plot_map(paleomap, main = "Scotese & Wright (2018)")
p5 <- plot_map(muller, main = "M\U00FCller et al. (2019)")
p6 <- plot_map(merdith, main = "Merdith et al. (2021)")

# Combine plots -----------------------------------------------------------
# Arrange plot
p <- ggarrange(p1, p2, p3, p4, p5, p6, ncol = 2, nrow = 3, labels = "AUTO",
               font.label = list(size = 18))
# Save plot
ggsave(filename = "./figures/continental_polygons.png",
       height = 250,
       width = 250,
       units = "mm",
       bg = "white",
       dpi = 600)
