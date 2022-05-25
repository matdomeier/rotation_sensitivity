
######################################################## VISUALISATION #########################################################

###### SIMULATION PART ######
## Plot and save latitude standard deviation time series ------------------------------
source("./scripts/visualisation/plot_lat_sd.R") #idem

## Plot and save the MST length assessment --------------------------------------------
source("./scripts/visualisation/plot_MST.R")

    ### FOR THE SCRIPT TO WRITE THE GIFS, SEE THE PYTHON NOTEBOOK "make_GIFs.ipynb"

## Plot and save barplot ncells = f(t) ------------------------------------------------
source("./scripts/visualisation/barplots.R")

## Assess, plot and barplots MST_len = f(t) for  ID_score categories ------------------
source("./scripts/data_analysis/quantification.R")



###### CASE STUDY ######
## Plot and save tropical/subtropical zone crossed reconstructions --------------------
source("./scripts/visualisation/plot_north_trop_lim_10Myrs_binning.R") #evolution of the northern subtropical limit (Gplates 10Myrs-step rotated occurrences)
source("./scripts/visualisation/plot_north_trop_lim_1Myrs_step.R") #same with chronosphere 1Myrs-step rotated occurrences
source("./scripts/visualisation/points_dist.R") #scatterplot with median/max/min lat

