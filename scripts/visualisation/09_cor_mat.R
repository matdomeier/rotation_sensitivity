# ------------------------------------------------------------------------- #
# Purpose: Run correlation tests between palaeolatitudinal extent of (sub)-tropics according to the 6 models and plot the results
# Author(s): Lucas Buffan & Lewis A. Jones
# Email: Lucas.L.Buffan@gmail.com; LewisAlan.Jones@uvigo.es
# Load libraries ----------------------------------------------------------
library(corrplot)
library(tidyr)
library(Hmisc)
## List of name equivalents between datasets and the paper ---------------
equiv_names <- c("GOLONKA" = "WR13",
                 "MATTHEWS2016" = "MAT16",
                 "MERDITH2021" = "MER21",
                 "MULLER2019" = "MUL19",
                 "PALEOMAP" = "SCO18",
                 "SETON2012" = "SET12")
## Core function ---------------------------------------------------------
correlation_plot <- function(org = c("corals", "crocs"), title, side = c("upper", "lower")){
  path <- paste0("./data/fossil_MaxLat_AllModels/", org, ".RDS")
  df <- readRDS(path)
  # Pivot based on models
  df_piv <- tidyr::pivot_wider(data = df,
                               names_from = model,
                               values_from = max)[, -c(1, 2)] #remove "time" and "entity" columns
  # Change model names to be consistent with the paper
  for(name in colnames(df_piv)){
    colnames(df_piv)[which(names(df_piv) == name)] = equiv_names[name]
  }
  # Run Pearson's correlation test out of the dataframe
  cor_res <- rcorr(as.matrix(df_piv), type = "pearson")
  # Set to 1e-12 p-values between same variables, otherwise set as NAs
  P_VAL <- cor_res$P
  for(i in 1:nrow(P_VAL)){
    P_VAL[i, i] = 1e-12
  }
  # Draw correlation matrix visual layout
  cor_plot <- corrplot(corr = cor_res$r,
                       col.lim = c(0, 1),
                       type = side,
                       title = title,
                       p.mat = P_VAL,
                       sig.level = 0.05,
                       tl.col = "black")
  return(cor_plot)
}

## Design final plot and save it ---------------------------------------
png("./figures/correlation_matrix.png",
    width = 50,
    height = 25,
    unit = "cm",
    res = 100)
par(mfrow = c(1,2))
correlation_plot(org = "corals", title = "Coral Reefs", side = "lower")
correlation_plot(org = "crocs", title = "Terrestrial Crocodylomorphs", side = "upper")
dev.off()
