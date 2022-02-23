
######################################################## VISUALISATION #########################################################


## set the background map -------------------------------------------------------------
source("./R/visualisation/background_map.R") #ignore warnings


## Plot and save latitude standard deviation time series ------------------------------
source("./R/visualisation/plot_lat_sd.R") #idem


## Plot and save latitude deviation 2 by 2 for all the models time series -------------
source("./R/visualisation/plot_lat_deviation.R")
    ### FOR THE SCRIPT TO WRITE THE GIFS, SEE THE PYTHON NOTEBOOK "make_GIFs.ipynb"


## Plot and save plateIDs assignement discrepancies -----------------------------------
source("./R/visualisation/plot_ID_weight.R")

