# Script details ----------------------------------------------------------
# Purpose: Prepare fossil reef data
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ---------------------------------------------------------
library(dplyr)
library(stringr)
library(raster)
# Load data --------------------------------------------------------------
PARED <- readRDS("./data/occurrences/raw_PARED_06_10_2021.RDS")
# Prepare PARED data -----------------------------------------------------
#retain only coral reefs
PARED <- subset(PARED, biota_main_t == "Corals" | biota_sec_text == "Corals")
#retain only outcropping reefs (subsurface reefs unreliable for affiliation)
PARED <- subset(PARED, subsurface_text == "Outcropping reef")
#retain only true reefs
PARED <- subset(PARED, type_text == "True reef")
#remove cold water/temperate coral reefs
PARED <- subset(PARED, tropical_text == "Tropical or unknown")
#assign mid-age
PARED$mid_ma <- (PARED$max_ma + PARED$min_ma) / 2
#retain only Scleractinian reefs 
PARED <- PARED[sapply(
  colnames(PARED), function(x) grep("Scleractinia", PARED[,x]))$biota_deta_text,]
#remove any coral reefs older than Anisian (247.2 Ma) implies non-scleractinian
PARED <- subset(PARED, max_ma < 247.2)
#exclude recent data
PARED <- subset(PARED, max_ma != 0)
# Time binning -----------------------------------------------------------
#assign to 10 myr time bins
#create empty columns for populating
PARED$bin_mid_ma <- NA
#whole of Phanerozoic
lower <- seq(from = 540, to = 10, by = -10)
mid <- seq(from = 535, to = 5, by = -10)
upper <- seq(from = 530, to = 0, by = -10)
#assign bins to data
for(i in 1:length(mid)){
  PARED[which(PARED$mid_ma <= lower[i] & PARED$mid_ma >= upper[i]),c("bin_mid_ma")] <- mid[i]
}
#update column names
names(PARED)[names(PARED) == c("latit")] <- c("lat") 
names(PARED)[names(PARED) == c("longit")] <- c("lng")
# Save data ----------------------------------------------------------------
saveRDS(PARED, "./data/occurrences/cleaned_PARED_dataset.RDS")
