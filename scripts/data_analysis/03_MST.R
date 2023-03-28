# Script details ----------------------------------------------------------
# Purpose: Calculate minimum-spanning tree length
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# WARNING: This script can take a while to run depending on the user's PC.
# Load libraries ----------------------------------------------------------
library(geosphere)
library(vegan)
# Timesteps  -------------------------------------------------------------
timescale <- seq(from = 10, to = 540, by = 10)
# Load model outputs -----------------------------------------------------
# Define available models
models <- c("MERDITH2021", "PALEOMAP", "GOLONKA",
            "MULLER2016", "SETON2012", "MATTHEWS2016_pmag_ref")

for (i in models) {
  assign(i, 
         readRDS(file = paste0("./data/grid_palaeocoordinates/", i, ".RDS")))
}

# Expand dfs to be consistent (use PALEOMAP as reference)
SETON2012[(ncol(SETON2012) + 1):ncol(PALEOMAP)] <- NA
MATTHEWS2016_pmag_ref[(ncol(MATTHEWS2016_pmag_ref) + 1):ncol(PALEOMAP)] <- NA
MULLER2016[(ncol(MULLER2016) + 1):ncol(PALEOMAP)] <- NA

# Update column names
colnames(SETON2012) <- colnames(PALEOMAP)
colnames(MATTHEWS2016_pmag_ref) <- colnames(PALEOMAP)
colnames(MULLER2016) <- colnames(PALEOMAP)

# Calculate MST ----------------------------------------------------------
# Generate empty matrix for populating
MST_mat <- matrix(0,
                  nrow = nrow(PALEOMAP),  
                  ncol = length(timescale) + 2
)
# Convert to dataframe
MST_df <- data.frame(MST_mat)
# Add reference coordinates
MST_df[, 1:2] <- PALEOMAP[, 1:2]
cnames <- c("lng", "lat")

# Run for loop across time
for (t in timescale) {
  cnames <- c(cnames, paste0("MST_length_", t))
    # Set up column index
    col_indx <- c(paste0("lng_", t), paste0("lat_", t))
  for (i in 1:nrow(MST_df)) {
    # Generate temp df for each model 
    tmp <- rbind(GOLONKA[i, col_indx],
                 MATTHEWS2016_pmag_ref[i, col_indx],
                 PALEOMAP[i, col_indx],
                 SETON2012[i, col_indx],
                 MERDITH2021[i, col_indx],
                 MULLER2016[i, col_indx])
    # Remove NAs
    tmp <- na.omit(tmp)
    # If only one point available no distance is calculated
    # Add NA value in these instances
    if (nrow(tmp) <= 1) {
      # Add to dataframe
      col_indx <- t / 10 + 2
      MST_df[i, col_indx] <- NA
      next
    }
    # Calculate distance matrix
    dist_mat <- distm(tmp, fun = distGeo)
    # Calculate MST
    mst_dist <- spantree(dist_mat)$dist
    # Sum tree and convert to km
    mst_dist <- sum(mst_dist) / 10^3
    # Add to dataframe
    col_indx <- t / 10 + 2
    MST_df[i, col_indx] <- mst_dist
  }
}
# Add column names
colnames(MST_df) <- cnames
# Save data
saveRDS(MST_df, "./results/MST_length.RDS")
