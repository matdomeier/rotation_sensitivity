# Evaluating the influence of model choice on palaeogeographic reconstructions in Palaeobiology

Our goal is to assess the impact of using different rotation models while reconstructing the surface of the Earth deep in time for Palaebiological purposes. Our study focuses on four of the most widely used open-sourced models. We first adopt a simulation approach, and compare the outputs of the models directy to assess how different they are. Next, we apply the models to two case studies, corals and terrestrial crocodiles datasets covering the last XXX Myrs, to illustrate the influence of using different models in the result that we obtain. This file details how the codes provided with this repository are linked to the analyses.

To facilitate the execution and make it as clear and reproducible as possible, the scripts are organised in a sense that to run all the analysis (except <strong>1.1</strong>), <strong>, you just have to execute the two masterfiles in the [MASTERFILE](https://github.com/Buffan3369/rotation_sensitivity/tree/main/scripts/MASTERFILES) folder </strong>. They will automatically source the other scripts.

## 1. Simulation approach: Assessing the differences between paleorotation models

### 1.1. Generation of the data

We generate our data using Gplates according to the following process:

<ol>
  <li> Creating a 1x1° meshgrid in a shapefile format
  <li> Opening it in Gplates
  <li> Merging it with continental polygons associated with a given model
  <li> Applying rotation to the resulting spatial data points with a 10 Myrs time step, going as far as the model goes
  <li> Exporting the results as shapefile polygons
</ol>

As, exept for generating the grid (see the first part of the [*rotating.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/rotating.R) script), this step doesn't involved coding, no script is provided for it. However, a scheme was made available in the supplementary materials. The output shapefiles were not provided with this repository, but if you want to have access to them please contact the main author.


### 1.2. Extracting the palaeocoordinates from Gplates' output

Model per model, we extract the coordinates of the rotated spatial data points in the polygons time series built in the previous step. We finally store them in one dataframe. We end-up having four dataframes, one per model, with as many rows as points (64800), and coordinates over time in columns (see second part of the [*rotating.R*](https://github.com/Buffan3369/rotation_sensitivity/blob/main/scripts/data_analysis/rotating.R) script).
The output files are provided [here](https://github.com/Buffan3369/rotation_sensitivity/tree/main/data/extracted_paleocoordinates).


### 1.3. 


22
