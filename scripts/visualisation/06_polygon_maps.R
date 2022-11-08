# ------------------------------------------------------------------------- #
# Purpose: Plot continental polygon maps
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(ggplot2)
library(sf)
# Load --------------------------------------------------------------------
# Load polygons and project to robinson

# Wright polygons
wright <- read_sf("./data/continental_polygons/Wright/Wright_PresentDay_ContinentalPolygons.shp")
# Robinson projection
wright <- st_transform(x = wright, crs = "ESRI:54030")

# Scotese polygons
scotese <- read_sf("./data/continental_polygons/Scotese2/Scotese2_PresentDay_ContinentalPolygons.shp")
# Retain only terrestrial plates
scotese <- scotese[which(scotese$DISAPPEARA == -999), ]
# Robinson projection
scotese <- st_transform(x = scotese, crs = "ESRI:54030")

# Matthews polygons
matthews <- read_sf("./data/continental_polygons/Matthews/Matthews_PresentDay_ContinentalPolygons.shp")
# Robinson projection
matthews <- st_transform(x = matthews, crs = "ESRI:54030")

# Seton polygons
seton <- read_sf("./data/continental_polygons/Seton/Seton_PresentDay_ContinentalPolygons.shp")
# Robinson projection
seton <- st_transform(x = seton, crs = "ESRI:54030")

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
p2 <- plot_map(wright, main = "Wright et al. (2013)")
p3 <- plot_map(matthews, main = "Matthews et al. (2016)")
p4 <- plot_map(scotese, main = "Scotese & Wright (2018)")

# Combine plots -----------------------------------------------------------
# Arrange plot
p <- ggarrange(p1, p2, p3, p4, ncol = 2, nrow = 2, labels = "AUTO",
               font.label = list(size = 18))
# Save plot
ggsave(filename = "./figures/continental_polygons.png",
       height = 150,
       width = 250,
       units = "mm",
       bg = "white",
       dpi = 600)
