# Script details ----------------------------------------------------------
# Purpose: Calculate average geodesic distance
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# WARNING: This script can take a while to run depending on the user's PC.
# Load libraries ----------------------------------------------------------
library(geosphere)
# Timesteps  -------------------------------------------------------------
timescale <- seq(from = 10, to = 540, by = 10)
# Load model outputs -----------------------------------------------------
# Define available models
models <- c("WR13", "TC16", "SC18", "ME21", "MA16")

# Load files rotated by Mat -----------------------------------------------
for (i in models) {
  assign(i,
         read.csv(file = paste0("./python/rotated_grids/", i, ".csv")))
}

# Expand MA16 to be temporally consistent with the scale of the study (Phanerozoic)
MA16[(ncol(MA16) + 1):ncol(SC18)] <- NA  # (use SC18 as reference)

# Update column names
colnames(MA16) <- colnames(SC18)

# Calculate average geodesic distance ------------------------------------
geodes_dist <- function(tmp_sub, in.km = TRUE){ #tmp_sub = c(lon_mdl1, lat_mdl2, lon_mdl2, lat_mdl2, ...)
  #convert subset to Lon Lat-like dataframe
  LonLat_mat <- matrix(data = tmp_sub, ncol = 2, nrow = length(tmp_sub)/2, byrow = TRUE)
  #remove Nas manually
  Na_pos <- unique(which(is.na(LonLat_mat[,1])),
                  which(is.na(LonLat_mat[,2])))
  if(length(Na_pos) == nrow(LonLat_mat)){
   return(NA)
  }
  else{
   if( (length(Na_pos) > 0) & (length(Na_pos) < nrow(LonLat_mat)) ){
     LonLat_mat <- LonLat_mat[-Na_pos, ]
   }
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
}


# Convert to dataframe with reference coordinates
geodes_dist_df <- data.frame(lng = SC18$lng,
                             lat = SC18$lat)
cnames <- c()
# Run for loop across time
for (t in timescale) {
  cnames <- c(cnames, paste0("Geodeic_dist_", t))
  col_indx <- c(paste0("lng_", t), paste0("lat_", t))
  tmp <- cbind(WR13[, col_indx],
                MA16_pmag_ref[, col_indx],
                SC18[, col_indx],
                TC16[, col_indx],
                ME21[, col_indx])
  GD_dist <- apply(X = tmp,
                       MARGIN = 1,
                       FUN = geodes_dist)
  geodes_dist_df <- cbind(geodes_dist_df, GD_dist)
}
# Add column names
colnames(geodes_dist_df) <- c("lng", "lat", cnames)
# Save data
saveRDS(geodes_dist_df, "./results/geodesic_distance.RDS")
