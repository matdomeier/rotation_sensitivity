# Script details ----------------------------------------------------------
# Purpose: Calculate latitudinal standard deviation
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(tidyverse)
library(matrixStats)
# Analysis ----------------------------------------------------------------
# Define available models
models <- c("MERDITH2021", "PALEOMAP", "GOLONKA",
            "MULLER2016", "SETON2012", "MATTHEWS2016_pmag_ref")

# Load files --------------------------------------------------------------
for (i in models) {
  assign(i, 
         readRDS(file = paste0("./data/grid_palaeocoordinates/", i, ".RDS")))
}
# Get reference coordinates
ref_coords <- SETON2012[, c("lng", "lat")]

# Update files ------------------------------------------------------------

# Expand dfs to be consistent (use PALEOMAP as reference frame)
SETON2012[(ncol(SETON2012) + 1):ncol(PALEOMAP)] <- NA
MATTHEWS2016_pmag_ref[(ncol(MATTHEWS2016_pmag_ref) + 1):ncol(PALEOMAP)] <- NA
MULLER2016[(ncol(MULLER2016) + 1):ncol(PALEOMAP)] <- NA


# Update column names
colnames(SETON2012) <- colnames(PALEOMAP)
colnames(MATTHEWS2016_pmag_ref) <- colnames(PALEOMAP)
colnames(MULLER2016) <- colnames(PALEOMAP)

# Get lat indexes columns for SD calculation
lat_indx <- grep("lat", colnames(PALEOMAP))

# Create empty dataframe for populating
df_sd <- matrix(ncol = length(lat_indx), nrow = nrow(PALEOMAP))
df_sd <- data.frame(df_sd)
# Add col names
colnames(df_sd) <- colnames(PALEOMAP)[lat_indx]

# Calculate row SD
for (i in 1:length(lat_indx)) {
  wc <- lat_indx[i]
  mat <- data.frame(SETON2012[, wc],
                    MATTHEWS2016_pmag_ref[, wc],
                    GOLONKA[, wc],
                    PALEOMAP[, wc],
                    MERDITH2021[, wc],
                    MULLER2016[, wc])
  row_sd <- apply(mat, 1, sd, na.rm = TRUE)
  df_sd[, i] <- row_sd
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
