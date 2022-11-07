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
models <- c("Scotese2", 
            "Matthews",  
            "Wright",
            "Seton")

for (i in models) {
  assign(i, 
         readRDS(file = paste0("./data/grid_paleocoordinates/", i, ".RDS")))
}

# Expand dfs to be consistent (use Scotese2 as reference frame)
Seton[(ncol(Seton) + 1):ncol(Scotese2)] <- NA
Matthews[(ncol(Matthews) + 1):ncol(Scotese2)] <- NA

# Update column names
colnames(Seton) <- colnames(Scotese2)
colnames(Matthews) <- colnames(Scotese2)

# Calculate MST ----------------------------------------------------------
# Generate empty matrix for populating
MST_mat <- matrix(0,
                  nrow = nrow(Matthews),  
                  ncol = length(timescale) + 2
)
# Convert to dataframe
MST_df <- data.frame(MST_mat)
# Add reference coordinates
MST_df[, 1:2] <- Matthews[, 1:2]
cnames <- c("lng", "lat")

# Run for loop across time
for (t in timescale) {
  cnames <- c(cnames, paste0("MST_length_", t))
  for (i in 1:nrow(MST_df)) {
    # Set up column index
    col_indx <- c(paste0("lon_", t), paste0("lat_", t))
    # Generate temp df for each model 
    tmp <- rbind(Wright[i, col_indx],
                    Seton[i, col_indx],
                    Scotese2[i, col_indx],
                    Matthews[i, col_indx])
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

