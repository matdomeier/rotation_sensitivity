# ------------------------------------------------------------------------- #
# Purpose: Plot latitudinal limits
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(ggplot2)
library(ggpubr)
library(deeptime)
pal <- rev(c('#41ab5d','#006837','#004529', '#dd3497','#7a0177','#49006a'))
shps <- c(3, 10, 15, 16, 17, 18, 20)
# Coral reef --------------------------------------------------------------
# List files
files <- list.files("./data/fossil_palaeocoordinates/corals/", full.names = TRUE)
# Models
models <- sub("_.*", "", sub(".*/", "", files))
# Coral Reefs
df <- data.frame(time = rep(seq(from = 5, to = 195, by = 10), times = 6),
                 entity = "Coral Reef",
                 max = NA,
                 model = rep(models, each = 20))
for (i in files) {
  # Temp model
  mdl <- sub("_.*", "", sub(".*/", "", i))
  # Load data
  tmp <- readRDS(i)
  # Extract columns
  tmp <- data.frame(entity = rep("Coral Reef", times = nrow(tmp)),
                    model = tmp$rot_model,
                    time = tmp$bin_mid_ma,
                    palaeolat = tmp$palaeolat)
  # Extract bins
  bins <- seq(from = 5, to = 195, by = 10)
  # Max lat per bin
  for (j in bins) {
    # If no vals available skip
    if (nrow(tmp[which(tmp$time == j), ]) == 0) {next}
    # If all values are NA, skip
    if (all(is.na(tmp[which(tmp$time == j), c("palaeolat")]))) {next}
    # Get maximum absolute latitude
    val <- max(abs(tmp[which(tmp$time == j), c("palaeolat")]), na.rm = TRUE)
    # Add to dataframe
    df$max[which(df$time == j & df$model == mdl)] <- val
  }
}

# Calculate ribbon coordinates
rib <- data.frame(time = bins, max = NA, min = NA, model = NA)
for (i in 1:nrow(rib)) {
  rib$max[i] <- max(df$max[which(df$time == rib$time[i])], na.rm = TRUE)
  rib$min[i] <- min(df$max[which(df$time == rib$time[i])], na.rm = TRUE)
}
# Update -Inf values (no coral reefs in this bin)
rib[which(is.infinite(rib$max)), c("max", "min")] <- NA

p1 <- ggplot(data = df, aes(x = time, y = max, colour = model, shape = model)) +
        #geom_line(size = 1) +
        geom_ribbon(data = rib, aes(x = time, ymin = min, ymax = max),
                    fill = "grey80",
                    colour = "grey80") +
        geom_point(size = 3, alpha = 0.75) +
        labs(title = "Coral Reefs",
             x = "Time (Ma)",
             y = "Absolute Palaeolatitude (\u00B0)",
             colour = "Model",
             shape = "Model") +
        scale_colour_manual(values = pal) +
        scale_shape_manual(values = shps) +
        scale_y_continuous(limits = c(0, 75), 
                           breaks = seq(0, 75, 15),
                           labels = seq(0, 75, 15)) + 
        scale_x_reverse(limits = c(200, 0)) +
        theme(plot.margin = margin(5, 10, 5, 10, "mm"),
              axis.title.x = element_text(size = 14),
              axis.title.y = element_text(size = 14),
              axis.text = element_text(size = 12),
              legend.background = element_blank(),
              legend.title = element_text(size = 10),
              legend.text = element_text(size = 8),
              legend.key.size = unit(0.4, "cm"),
              legend.position = c(0.83, 0.85),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(), 
              panel.background = element_blank(),
              panel.border = element_rect(colour = "black", fill = NA, size = 0.5)) +
        deeptime::coord_geo(pos = "bottom", fill = "grey95", height = unit(1.5, "line")) +
  guides(colour=guide_legend(ncol=2))
# Crocs -------------------------------------------------------------------
# List files
files <- list.files("./data/fossil_palaeocoordinates/crocs/", full.names = TRUE)
# Models
models <- sub("_.*", "", sub(".*/", "", files))
# Crocs
df <- data.frame(time = rep(seq(from = 5, to = 195, by = 10), times = 6),
                 entity = "Crocodylomorphs",
                 max = NA,
                 model = rep(models, each = 20))

for (i in files) {
  # Temp model
  mdl <- sub("_.*", "", sub(".*/", "", i))
  # Load data
  tmp <- readRDS(i)
  # Extract columns
  tmp <- data.frame(entity = rep("Crocodylomorphs", times = nrow(tmp)),
                    model = tmp$rot_model,
                    time = tmp$bin_mid_ma,
                    palaeolat = tmp$palaeolat)
  # Extract bins
  bins <- seq(from = 5, to = 195, by = 10)
  # Max lat per bin
  for (j in bins) {
    # If no vals available skip
    if (nrow(tmp[which(tmp$time == j), ]) == 0) {next}
    # Get maximum absolute latitude
    val <- max(abs(tmp[which(tmp$time == j), c("palaeolat")]), na.rm = TRUE)
    # Add to dataframe
    df$max[which(df$time == j & df$model == mdl)] <- val
  }
}

# Calculate ribbon coordinates
rib <- data.frame(time = bins, max = NA, min = NA, model = NA)
for (i in 1:nrow(rib)) {
  rib$max[i] <- max(df$max[which(df$time == rib$time[i])])
  rib$min[i] <- min(df$max[which(df$time == rib$time[i])])
}

p2 <- ggplot(data = df, aes(x = time, y = max, colour = model, shape = model)) +
        #geom_line(size = 1) +
        geom_ribbon(data = rib, aes(x = time, ymin = min, ymax = max),
                    fill = "grey80",
                    colour = "grey80") +
        geom_point(size = 3, alpha = 0.75) +
        labs(title = "Crocodylomorphs",
             x = "Time (Ma)",
             y = "Absolute Palaeolatitude (\u00B0)",
             colour = "Model",
             shape = "Model") +
        scale_colour_manual(values = pal) +
        scale_shape_manual(values = shps) +
        scale_y_continuous(limits = c(15, 90), 
                           breaks = seq(15, 90, 15),
                           labels = seq(15, 90, 15)) + 
        scale_x_reverse(limits = c(200, 0)) +
        theme(plot.margin = margin(5, 10, 5, 10, "mm"),
              axis.title.x = element_text(size = 14),
              axis.title.y = element_text(size = 14),
              axis.text = element_text(size = 12),
              legend.background = element_blank(),
              legend.title = element_text(size = 10),
              legend.text = element_text(size = 8),
              legend.key.size = unit(0.4, "cm"),
              legend.position = c(0.18, 0.85),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(), 
              panel.background = element_blank(),
              panel.border = element_rect(colour = "black", fill = NA, size = 0.5)) +
        deeptime::coord_geo(pos = "bottom", fill = "grey95", height = unit(1.5, "line")) +
  guides(colour=guide_legend(ncol=2))

# Combine plots -----------------------------------------------------------
# Arrange plot
p <- ggarrange(p1, p2, ncol = 1, nrow = 2, labels = "AUTO",
               font.label = list(size = 20))
# Save plot
ggsave(filename = "./figures/tropical_extent.png",
       height = 250,
       width = 210,
       units = "mm",
       dpi = 600)
