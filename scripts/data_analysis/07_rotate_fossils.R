# Script details ----------------------------------------------------------
# Purpose: Rotate fossil occurrences
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(palaeoverse)
library(tibble)
## Let's rotate -----------------------------------------------------------
# Which models should be used?
models <- c("PALEOMAP",
            "SETON2012",
            "MATTHEWS2016_pmag_ref",
            "GOLONKA") # This names refers to the WRIGHT model!!

# Corals reconstruction ---------------------------------------------------
for (m in models) {
  # Load data
  df <- readRDS("./data/occurrences/cleaned_PARED_dataset.RDS")
  # Rotate occurrences
  df <- palaeorotate(occdf = df, age = "mid_ma", method = "point", model = m)
  # Update column names
  colnames(df)[which(colnames(df) == "p_lng")] <- "palaeolng"
  colnames(df)[which(colnames(df) == "p_lat")] <- "palaeolat"
  saveRDS(df, paste0("./data/fossil_palaeocoordinates/corals/", m, "_mid_ma.RDS"))
}

# Croc reconstruction ---------------------------------------------------
for (m in models) {
  # Load data
  df <- readRDS("./data/occurrences/cleaned_croc_dataset.RDS")
  # Rotate occurrences
  df <- palaeorotate(occdf = df, age = "mid_ma", method = "point", model = m)
  # Update column names
  colnames(df)[which(colnames(df) == "p_lng")] <- "palaeolng"
  colnames(df)[which(colnames(df) == "p_lat")] <- "palaeolat"
  saveRDS(df, paste0("./data/fossil_palaeocoordinates/crocs/", m, "_mid_ma.RDS"))
}
