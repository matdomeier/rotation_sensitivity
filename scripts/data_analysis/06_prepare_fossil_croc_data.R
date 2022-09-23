# Script details ----------------------------------------------------------
# Purpose: Prepare fossil croc data
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(dplyr)
library(tibble)
# Read data ---------------------------------------------------------------
#Read croc data
crocs <- readRDS(file = "./data/occurrences/raw_PBDB_croc_dataset.RDS")
#Analyses focused on terrestrial taxa, remove all marine taxa from database
marine_taxa <- read.delim("./data/occurrences/marine_taxa.txt", header = FALSE)[,1]
#filter data from PBDB classification
crocs <- crocs %>% filter(!family %in% marine_taxa)
crocs <- crocs %>% filter(!genus %in% marine_taxa)
crocs <- crocs %>% filter(!accepted_name %in% marine_taxa)
#remove all form and ichnotaxa occurrence data
crocs <- crocs %>% filter(!flags %in% c("IF", "F", "I"))
#add mid_ma col
crocs <- crocs %>% add_column(mid_ma = (crocs$max_ma + crocs$min_ma) / 2,
                            .before = "min_ma")

# Time binning ------------------------------------------------------------
#assign to 10 myr time bins
#create empty columns for populating
crocs$bin_mid_ma <- NA

#whole of Phanerozoic
lower <- seq(from = 540, to = 10, by = -10)
mid <- seq(from = 535, to = 5, by = -10)
upper <- seq(from = 530, to = 0, by = -10)

#assign bins to data
for(i in 1:length(mid)){
  crocs[which(
    crocs$mid_ma <= lower[i] & crocs$mid_ma >= upper[i]),c("bin_mid_ma")] <- mid[i]
}

# Save data ---------------------------------------------------------------
saveRDS(crocs, "./data/occurrences/cleaned_croc_dataset.RDS")
