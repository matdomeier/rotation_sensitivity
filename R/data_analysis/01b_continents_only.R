# Script details ----------------------------------------------------------
# Purpose: Eliminate oceanic cells from model files
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(hash)

# Define available models
models <- c("WR13", "TC16", "SC18", "ME21", "MA16")

# Load files (uncomment as soon as we get files from Sabin) ---------------
# for (i in models) {
#   assign(i, 
#          readRDS(file = paste0("./data/grid_palaeocoordinates/", i, ".RDS")))
# }

# Load files rotated by Mat -----------------------------------------------
for (i in models) {
  assign(i,
         read.csv(file = paste0("./python/rotated_grids/", i, ".csv")))
}

# Get reference ( = present-day) coordinates
ref_coords <- SC18[, c("lng", "lat")]

# Update files ------------------------------------------------------------

# Expand MA16 to be temporally consistent with the scale of the study (Phanerozoic)
MA16[(ncol(MA16) + 1):ncol(SC18)] <- NA  # (use SC18 as reference)

# Update column names
colnames(MA16) <- colnames(SC18)

# Eliminate present-day cells that are not covered by at least one model 
not_covered <- hash::hash(keys = models,
                          values = rep(NA, length(models)))
for(model in ls(not_covered)){
  df <- get(model)
  not_covered[[model]] <- length(which(is.na(df[, "lat_10"])))
}
#which.max(values(not_covered)) = TC16
print(paste0("TC16 has the maximum number of uncovered cells (",max(values(not_covered)),
             ") : we therefore scale all other model's spatial coverage to that (i.e. remove oceans)."))
to_remove <- which(is.na(TC16$lng_10))
rm_idx <- function(model, rm_indices){
  mdl_df <- get(model)
  return(mdl_df[-rm_indices, ])
}

for(model in models){
  tmp <- rm_idx(model = model,
                rm_indices = to_remove)
  saveRDS(tmp,
          paste0("./data/mdls_without_oceans/", model, ".RDS"))
}
