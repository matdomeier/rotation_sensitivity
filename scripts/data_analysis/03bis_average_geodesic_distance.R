# Script details ----------------------------------------------------------
# Purpose: Calculate minimum-spanning tree length
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# WARNING: This script can take a while to run depending on the user's PC.
# Load libraries ----------------------------------------------------------
library(geosphere)
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

# Expand dfs to be consistent (use PALEOMAP as reference frame)
SETON2012[(ncol(SETON2012) + 1):ncol(PALEOMAP)] <- NA
MATTHEWS2016_pmag_ref[(ncol(MATTHEWS2016_pmag_ref) + 1):ncol(PALEOMAP)] <- NA
MULLER2016[(ncol(MULLER2016) + 1):ncol(PALEOMAP)] <- NA

# Update column names
colnames(SETON2012) <- colnames(PALEOMAP)
colnames(MATTHEWS2016_pmag_ref) <- colnames(PALEOMAP)
colnames(MULLER2016) <- colnames(PALEOMAP)

# Calculate average geodesic distance ------------------------------------
geodes_dist <- function(tmp_sub, in.km = TRUE){ #tmp_sub = c(lon_mdl1, lat_mdl2, lon_mdl2, lat_mdl2, ...)
  #convert subset to Lon Lat-like dataframe
  LonLat_mat <- matrix(data = tmp_sub, ncol = 2, nrow = length(tmp_sub)/2, byrow = TRUE)
  #distance matrix
  dist_mat <- distm(LonLat_mat, fun = distGeo)
  #vector of the pairwise distances between points in dist_mat
  pairwise_dist <- as.numeric(dist_mat[upper.tri(dist_mat, diag = FALSE)])
  if(in.km == TRUE){
    return(mean(pairwise_dist)/(10**3))
  }
  else{
    return(mean(pairwise_dist))
  }
}

# Convert to dataframe with reference coordinates
geodes_dist_df <- data.frame(lng = PALEOMAP$lng,
                             lat = PALEOMAP$lat)
cnames <- c()
# Run for loop across time
for (t in timescale) {
  cnames <- c(cnames, paste0("MST_length_", t))
  col_indx <- c(paste0("lng_", t), paste0("lat_", t))
  tmp <- cbind(GOLONKA[, col_indx],
                MATTHEWS2016_pmag_ref[, col_indx],
                PALEOMAP[, col_indx],
                SETON2012[, col_indx],
                MERDITH2021[, col_indx],
                MULLER2016[, col_indx])
  GD_dist <- apply(X = tmp,
                       MARGIN = 1,
                       FUN = geodes_dist)
  geodes_dist_df <- cbind(geodes_dist_df, GD_dist)
}
# Add column names
colnames(geodes_dist_df[, 3:ncol(geodes_dist_df)]) <- cnames
# Save data
saveRDS(geodes_dist_df, "./results/geodesic_distance.RDS")
