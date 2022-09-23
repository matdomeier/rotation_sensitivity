# Script details ----------------------------------------------------------
# Purpose: Rotate fossil occurrences
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(chronosphere)
library(tibble)
## Let's rotate -----------------------------------------------------------
# Which models should be used?
models <- c("PALEOMAP",
            "SETON2012",
            "MATTHEWS2016",
            "GOLONKA") # This names refers to the WRIGHT model!!

# Corals reconstruction ---------------------------------------------------
for (m in models) {
  # Load data
  df <- readRDS("./data/occurrences/cleaned_PARED_dataset.RDS")
  # Round age for GPlates
  df$round_age <- round(df$mid_ma)
  # Add empty columns
  df$palaeolat <- NA
  df$palaeolng <- NA
  # Rotate over rounded ages
  for (i in unique(df$round_age)) {
    vec <- which(df$round_age == i)
    pcoords <- data.frame(reconstruct(x = df[vec, c("lng", "lat")],
                age = i,
                model = m))
    df$palaeolng[vec] <- pcoords[, 1]
    df$palaeolat[vec] <- pcoords[, 2]
  }
  saveRDS(df,
    paste0("./data/fossil_extracted_paleocoordinates/corals/", m, "_mid_ma.RDS"))
}

# Croc reconstruction ---------------------------------------------------
for (m in models) {
  # Load data
  df <- readRDS("./data/occurrences/cleaned_croc_dataset.RDS")
  # Round age for GPlates
  df$round_age <- round(df$mid_ma)
  # Add empty columns
  df$palaeolat <- NA
  df$palaeolng <- NA
  # Rotate over rounded ages
  for (i in unique(df$round_age)) {
    vec <- which(df$round_age == i)
    pcoords <- data.frame(reconstruct(x = df[vec, c("lng", "lat")],
                                      age = i,
                                      model = m))
    df$palaeolng[vec] <- pcoords[, 1]
    df$palaeolat[vec] <- pcoords[, 2]
  }
  saveRDS(df,
          paste0("./data/fossil_extracted_paleocoordinates/crocs/", m, "_mid_ma.RDS"))
}
