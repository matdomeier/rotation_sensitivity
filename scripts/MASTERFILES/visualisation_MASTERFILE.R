
######################################################## VISUALISATION #########################################################

###### SIMULATION PART ######
## set the background map -------------------------------------------------------------
source("./scripts/visualisation/background_map.R") #nb: ignore warnings

## Plot and save latitude standard deviation time series ------------------------------
source("./scripts/visualisation/plot_lat_sd.R") #idem

## Plot and save latitude deviation 2 by 2 for all the models time series -------------
source("./scripts/visualisation/plot_lat_deviation.R")

## Plot and save the MST length assessment --------------------------------------------
source("./scripts/visualisation/plot_MST.R")

    ### FOR THE SCRIPT TO WRITE THE GIFS, SEE THE PYTHON NOTEBOOK "make_GIFs.ipynb"

## Plot and save plateIDs assignement discrepancies -----------------------------------
source("./scripts/visualisation/plot_ID_score.R")

## Plot and save time series for the three selected frames ----------------------------
source("./scripts/visualisation/time_series_frames.R")

## Plot and save barplot ncells = f(t) ------------------------------------------------
source("./scripts/visualisation/barplots.R")

## Assess, plot and barplots MST_len = f(t) for  ID_score categories ------------------
source("./scripts/data_analysis/quantification.R")



###### CASE STUDY ######
## Plot and save tropical/subtropical zone crossed reconstructions --------------------
source("./scripts/visualisation/plot_north_trop_lim.R") #evolution of the northern subtropical limit