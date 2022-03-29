# Evaluating the influence of model choice on palaeogeographic reconstructions in Palaeobiology

Our goal is to assess the impact of using different plates rotation models while reconstructing the surface of the Earth deep in time for Palaebiological purposes. Our study focuses on four of the most widely used open-sourced models. We first adopt a simulation approach, and compare the outputs of the models directly across the entire Phanerozoic to assess how different they are. Next, we apply the models to two palaeobiological datasets for two taxa that can be used as proxies of either the subtropics or the tropics: terrestrial crocodiles and coral reefs. The latter part covers the last 200 Ma, and aims to illustrate the repercussion of the differences between models in a palaeobiological framework. This file details how the codes provided with this repository are linked to the analyses.

To facilitate the execution and make it as clear and reproducible as possible, the scripts are organised in a sense that to run all the analysis (except <strong>1.1</strong>), <strong>, you just have to open the Rproject [rot_sens.Rproj](https://github.com/Buffan3369/rotation_sensitivity/blob/main/rot_sens.Rproj) and, from there, execute the two masterfiles in the [MASTERFILE](https://github.com/Buffan3369/rotation_sensitivity/tree/main/scripts/MASTERFILES) folder </strong>. They will automatically source the other scripts.

## 1. Simulation approach: Assessing the differences between paleorotation models

### 1.1. Generating the data

We generate our data using Gplates according to the following process:

<ol>
  <li> Creating a 1x1° meshgrid in a shapefile format
  <li> Opening it in Gplates
  <li> Merging it with continental polygons associated with a given model
  <li> Applying rotation to the resulting spatial data points with a 10 Myrs time step, going as far as the model goes
  <li> Exporting the results as shapefile polygons
</ol>

As, exept for generating the grid (see the first part of the [*rotating.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/rotating.R) script), this step doesn't involve coding, hence no script is provided for it. However, a scheme was made available in the supplementary materials. As they were too heavy (>7Go), the output shapefiles were not provided with this repository. If you feel the need to have access to them please contact the main author.


### 1.2. Extracting the palaeocoordinates from Gplates' output

Model per model, we extract the coordinates of the rotated spatial data points in the polygons time series built in the previous step. We finally store them in one dataframe. We end-up having four dataframes, one per model, with as many rows as points (64800), and coordinates over time in columns (see second part of the [*rotating.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/rotating.R) script).
The output files are provided [here](https://github.com/Buffan3369/rotation_sensitivity/tree/main/data/extracted_paleocoordinates).


### 1.3. Georeferencing and spatial scaling of the outputs

The georeferencing step consists of re-assigning to each spatial point the ID of the plate it belongs to, according to the four models. Due to models' spatial coverage, some points may be assigned no plate. These are tracked by the `get_na_pos()` function. (see [*georeferencing_and_NA_pos.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/georeferencing_and_NA_pos.R)). 

As not all model have the same spatial coverage, before we compare the outputs of the models together, a spatial scaling step is needed. The procedure involves to select the model with the smallest spatial coverage by minimising the `get_na_pos()` function previously introduced. This model reveals to be Golonka (34651 cells). We therefore set as NA the values of these cells for all our models, and the cells that are not covered by the output of at least one of the three other models imputed from Golonka’s 34651 ones. This finally led us to work with n=29500 cells (see [*cells_to_drop.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/cells_to_drop.R)).


### 1.4. Comparing the outputs

#### 1.4.1. Latitudinal standard deviation assessment

We used our scaled georeferenced outputs to estimate, time interval per time interval and cell by cell, the standard deviation between the four latitude reconstructions (see [*lat_sd.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/lat_sd.R)) and projected the results on a present-day map (see [*plot_lat_deviation.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/visualisation/plot_lat_deviation.R) and [*background_map.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/visualisation/background_map.R) for the background map). We store the resulting standard deviation in [this folder](https://github.com/Buffan3369/rotation_sensitivity/tree/main/figures/standard_deviation).

#### 1.4.2. Latitudinal deviation assessment

We also estimated and plotted the same way the deviation in the latitude estimation between the outputs of the models two by two, expressed as the absolute value of the difference between the reconstructed latitudes according to the two models (see [*lat_dev_2_by_2.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/lat_dev_2_by_2.R) and [*plot_lat_deviation.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/visualisation/plot_lat_deviation.R)).

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

