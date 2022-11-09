# Script details ----------------------------------------------------------
# Purpose: Calculate latitudinal standard deviation
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(tidyverse)
library(matrixStats)
# Analysis ----------------------------------------------------------------
# Define available models and their temporal extent
models <- c("Scotese2",  #PALEOMAP latest version
            "Matthews",  
            "Wright",
            "Seton")

MaxTime <- list("Scotese2" = 540,
             "Matthews" = 410,
             "Wright" = 540, # Rounded to 540 (instead of 544) for Wright
             "Seton" = 200)

# Load files --------------------------------------------------------------
for (i in models) {
  assign(i, 
         readRDS(file = paste0("./data/grid_palaeocoordinates/", i, ".RDS")))
}
# Get reference coordinates
ref_coords <- Seton[, c("lon_0", "lat_0")]
colnames(ref_coords) <- c("lng", "lat")

# Update files ------------------------------------------------------------

# Expand dfs to be consistent (use Scotese2 as reference frame)
Seton[(ncol(Seton) + 1):ncol(Scotese2)] <- NA
Matthews[(ncol(Matthews) + 1):ncol(Scotese2)] <- NA

# Update column names
colnames(Seton) <- colnames(Scotese2)
colnames(Matthews) <- colnames(Scotese2)

# Get lat indexes columns for SD calculation
lat_indx <- grep("lat", colnames(Scotese2))

# Create empty dataframe for populating
df_sd <- matrix(ncol = length(lat_indx), nrow = nrow(Scotese2))
df_sd <- data.frame(df_sd)
# Add col names
colnames(df_sd) <- colnames(Scotese2)[lat_indx]

# Calculate row SD
for (i in 1:length(lat_indx)) {
  wc <- lat_indx[i]
  mat <- data.frame(Seton[, wc], Matthews[, wc], Wright[, wc], Scotese2[, wc])
  mat <- as.matrix.data.frame(mat)
  df_sd[, i] <- rowSds(mat, na.rm = TRUE)
}

# Tidy up and save --------------------------------------------------------
df_sd <- cbind.data.frame(ref_coords, df_sd)
saveRDS(df_sd, file = "./results/lat_SD.RDS")

## Ncells counter ---------------------------------------------------------
ncells_over_time <- vector("numeric")
# Count number of NA cells over time
for (i in 1:(ncol(df_sd) - 2)) {
  ncells_over_time[i] <- length(which(!is.na(df_sd[, i])))
}
t <- seq(from = 0, to = 540, by = 10)
plot(x = t, y = ncells_over_time)
