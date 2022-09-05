# Spatial discrepancies between plate rotation models in the reconstruction of macroecological patterns

We evaluated the impact of using different plate rotation models to reconstruct the surface of the Earth over geological timescales. Our study focuses on four of the most widely used open-source models. We first adopt a simulation approach, and compare model reconstructions from the entire Phanerozoic to test for spatiotemporal discrepancies. Next, using empirical data with the plate rotation models, we reconstruct the distribution of two entities that serve as proxies of tropical/subtropical conditions: terrestrial crocodiles and coral reefs. The latter approach (with empirical data) covers the last 200 Myr, and aims to illustrate the impact of model choice within a palaeobiological framework. Below, we detail how the code provided within this repository are linked to the analyses.

To implement the execution and enable reproducibility, the scripts are organised in a way that to run the analyses (except **1.1**), you must open **rot_sens.Rproj** in RStudio and execute the two files in the MAIN folder. They will automatically source the other scripts.

## 1. Simulation approach: Assessing the differences between paleorotation models

### 1.1. Generating the data

We generate our data using [GPlates](https://www.gplates.org) according to the following process:

1. Create a 1&deg; x 1&deg; grid (stored as a `.shp` file). For the code producing the grid see `scripts/data_analysis/rotation.R`.
1. Open the `.shp` in GPlates
1. Assign plate IDs (i.e. georeference cell centroids to continental polygons) for each model.
1. Rotate cell centroids for each model with a 10 Myr time step across the temporal range of the model.
1. Exporting the results as a `.shp` file for processing in `R`.

As the spatial grid was rotated using the GPlates interface, no script is provided for this part of the study. However, a schematic was produced and is available in the supplementary material for reviewing. As the generated `.shp` files are heavy (> 1 GB), they are not provided within this repository. The user may reproduce these `.shp` files by using the provided code, or contacting the main author.

### 1.2. Extracting the palaeocoordinates from GPlates' output

For each model, we extract the palaeocoordinates of the rotated cell centroids across our studied time series and wrangle this data into a single dataframe, resulting in four dataframes with each containing 64,800 rows (the number of cells within a 1&deg; x 1&deg; grid), and coordinate pairs over time in columns (see second part of the `/scripts/data_analysis/rotating.R` script).
The output file for each model is provided in `/data/extracted_paleocoordinates/`.

### 1.3. Georeferencing and spatial scaling of the outputs

In `R`, we conduct further processing and assign plate IDs to each cell centroid according to the four models. We do so due to varying spatial coverage between models (i.e. some cell centroids may not be assigned to any plate). These are tracked by the `get_na_pos()` function (`/scripts/data_analysis/georeferences_and_NA_pos.R`). We then apply it to the four models and identify which cells are not covered by at least one model (those cells are excluded from analysis as they are interpreted as non-continental zones).

### 1.4. Comparing model outputs

#### 1.4.1. Latitude and longitude

We used our scaled outputs to estimate the standard deviation of palaeolatitude and palaeolongitude from the four models (see `scripts/data_analysis/lat_sd.R`) and projected the results onto a present-day map (see `scripts/visualisation/plot_lat_deviation.R` and `scripts/visualisation/background_map.R`). We store the resulting plots in `figures/standard_deviaton/`.

#### 1.4.2. Latitudinal deviation assessment

We also calculated (and plotted) pairwise deviation in palaeolatitude between model outputs, expressed as the absolute value of the difference between the reconstructed latitudes according to the two models (see `scripts/data_analysis/lat_dev_2_by_2.R` and `scripts/visualisation/plot_lat_deviation.R`).

#### 1.4.3. Plate discrepancies assessment

Furthermore, we introduced the ID_weight metric evaluating, for each of the 29500 spatial points, the number of different plateIDs it has been assigned to according to all the models -- except Seton, as we faced troubles dealing with its plates partitioning. The ID_weight therefore ranges from 1 (all models agree and assign the point to the same plateID), to 3 (all model disagree) (see [*ID_weight.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/ID_weight.R)). This metric was then projected onto a global map (see [*plot_ID_weight.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/visualisation/plot_ID_weight.R)).
The resulting figure is available [here](https://github.com/Buffan3369/rotation_sensitivity/blob/main/figures/PlateID_discrepancies.png).

#### 1.4.4. Minimum Spanning Tree (MST) length

To best spatially figure out how different the outputs of the models are, we compute, for each of our 29500 points and at a given time, the length of the Minimum Spanning Tree connecting the centroids of the projection of the point according to the four models and plot this on a present-day map. This metric is a proxy of the geographical spread arising when comparing the models (see [*MST.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/MST.R) and [*plot_MST.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/visualisation/plot_MST.R)).


*nb: these analyses involved producing time-series maps that were further assembled in GIFs with the detailed procedure in the [*make_GIFS.ipynb](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/make_GIFs.ipynb) notebook, designed to be run in Google Colab.*


## 2. Case study: quantifying the repercussions of the differences between plate models on a true biological analysis

### 2.1. Fossil data pre-processing
#### 2.1.1. Crocodiles

We download all Crocodylomorpha occurrences from [The Paleobiology Database](https://paleobiodb.org/#/) and we filter out all marine taxa, as their past distribution was shown [not to exhibit any climate-driven pattern](https://www.nature.com/articles/ncomms9438). This made us work with 4205 occurrences (see [*prepare_fossil_croc_data.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/prepare_fossil_croc_data.R)).

#### 2.1.2. Coral reefs

We use all Reefs occurrences from [The Paleo Reefs Database](https://www.paleo-reefs.pal.uni-erlangen.de/), and filter in Tropical (warm-water) coral reefs with Scelarctinian skeleton, main current indicators of the tropics. We ended up having 420 occurrences (see [*prepare_fossil_reef_data.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/prepare_fossil_reef_data.R)).

### 2.2. Rotating occurrences 

As the occurrences are not provided with an absolute age estimate but within an age interval, we rotate each occurrence for its corresponding mid-age rounded to the nearest Myrs, using the `reconstruct()` function of the [Chronosphere](https://cran.r-project.org/web/packages/chronosphere/index.html) R package (see [*rotate_fossils_with_chronosphere.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/rotate_fossils_with_chronosphere.R)).

### 2.3. Analysis
#### 2.3.1. Tropics and subtropics reconstruction in deep time

For each taxon, we represent the minimum, maximum and median occurrence's latitude reconstruction over time (see [points_dist.R](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/visualisation/points_dist.R)). Furthermore, we plot the extrapolated northern (sub)tropical limit from the latter representation, given as the temporal interpolation between the most northern occurrences of each taxon at each time step (see [plot_north_trop_lim.R](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/visualisation/plot_north_trop_lim.R)).

#### 2.3.2. Quantification of the amount of occurrences in different ID_score zones

According to the partitioning of the globe in zones of different ID_scores we proposed in <strong>1.4.3.</strong>, we quantify the amount of fossil occurrences present in each zone of different ID_score (see [quantify_percent_occ_risky](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/quantify_percent_occ_risky.R)).

