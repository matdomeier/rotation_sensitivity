# ------------------------------------------------------------------------- #
# Purpose: Plot phylogenetic tree representing relations between models
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(phytools)
library(ape)
# Time-calibrated tree based on year of reease of each model --------------
models.nwk <- "((DOM14:5,(DOM16:6,(DOM18:7):1)):11,(SCO18:18,(WR13:6,(SET12:2,MUL16:6,MAT16:6,MUL19:9):3,(MER17:4,MER21:8):5):7):1);"
tree <- read.newick(text = models.nwk)
# Plot --------------------------------------------------------------------
png(filename = "./figures/raw_phylogeny.png",
    height = 200,
    width = 200,
    units = "mm",
    res = 500)
plotTree(tree)
dev.off()