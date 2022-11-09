# Mind the uncertainty! Global Plate Model choice impacts past biogeographic reconstructions

Author(s): [Lucas Buffan](lucas.buffan@ens-lyon.fr), [Lewis A. Jones](mailto:LewisA.Jones@outlook.com), Christopher R. Scotese, Sabin Zahirovic, Mathew Domeier, and [Sara Varela](sara.varela@uvigo.es).

This repository contains the data and code required to run the analyses and results of the article, "Mind the uncertainty! Global Plate Model choice impacts past biogeographic reconstructions" (Buffan et al. 2022). 

To cite the paper: 
> Lucas Buffan, Lewis A. Jones, Christopher R. Scotese, Sabin Zahirovic, Mathew Domeier, and Sara Varela. 2022. Mind the uncertainty! Global Plate Model choice impacts past biogeographic reconstructions.

![](figures/standard_deviation/time_series.gif)

![](figures/MST/time_series.gif)

-------

## Study details

In this study, we evaluate the impact of using different plate rotation models to reconstruct the distribution of the Earth's surface over geological timescales. Our study focused on five of the most widely used open-source models available via the [GPlates Web Service](https://gwsdoc.gplates.org/reconstruction-models):

* MERDITH model (Merdith et al., 2021) - GPlates ID = MERDITH2021
* PALEOMAP model (Scotese & Wright, 2018) - GPlates ID = PALEOMAP
* MATTHEWS model (Matthews et al., 2016) - GPlates ID = MATTHEWS2016_pmag_ref
* GOLONKA model (Wright et al., 2013) - GPlates ID = GOLONKA
* SETON model (Seton et al., 2012) - GPlates ID = SETON2012

We first adopt a simulation approach to evaluate spatiotemporal discrepancies in palaeogeographic reconstructions between the four models. Subsequently, using empirical data, we reconstructed the palaeodistribution of two entities that serve as proxies of tropical/subtropical conditions: terrestrial crocodylomorphs and coral reefs. The latter approach (with empirical data) covers the last 200 Myr, and aims to illustrate the impact of model choice within a palaeobiological framework.

-------
## Repository structure

In this repository, files and code are organised as:

* **Data** files are stored in the `/data/` folder
* **Analysis** code in the `/scripts/` folder
* **Results** in the `/results/` folder
* **Figures** in the `/figures/` folder

-------

## Workflow

The workflow and documentation for data analysis can be found in: `/scripts/data_analysis.R`.

The workflow for data visualisation can be found in: `/scripts/visualiation.R`.

Documentation and comments relating to the workflow can be found within the aforementioned scripts, as well as the subscripts.
