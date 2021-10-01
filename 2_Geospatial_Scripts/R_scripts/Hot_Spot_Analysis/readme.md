<p align="center">
  <img width="460" height="300" src="https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/HSGrid.png">
</p>

<h2>
<p align="center">
  <strong><a href="https://github.com/ICPI/GIS/tree/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS">[FACILITY] Hotspot Tool Link</a></strong>
</p>

<p align="center">
  <strong><a href="https://github.com/ICPI/GIS/tree/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/PSNU_HS">[PSNU] Hotspot Tool Link (Depreciated)</a></strong>
</p>
</h2>

<br><br/>

# WHAT IS THIS TOOL?

This tool is an R script created to emulate QGIS’s experimental Getis-Ord hot spot plug-in. This script allows users to preform a spatial hot spot analysis without the use of traditional GIS software such as QGIS and ArcGIS. While there are numerous other more detailed methods of preforming this analysis, this process was chosen as the most accessible to beginners of statistics and R. To simplify the process further, both facility and PSNU scripts will use the same method. 

Users will need to have a basic understanding of R to execute this tool.

<br><br/>

# QUICK BREAKDOWN OF OPTIONS:

In the links below, you will find two options for facility or PSNU based analysis. Depending on user needs, users will likely only need one option. 

*A version of the facility script for programmatic data with its own coordinates is currently under development.*

Both pages will contain a link to the script itself and a detailed breakdown of every line of code. Please download the script and follow the explanations as needed. Each version of the script will have approximately 6 sections with several optional components. 

*A self-contained script that can be run online using Juptyer Notebooks is currently under development.*

<br><br/>

# DATA NEEDED FOR THIS TOOL:

To keep everything concise and easier to follow, users will need the following datasets before running the script:

When running a PSNU-based analysis:
* PEPFAR OU polygon shapefile [Correctly Projected]
* Programmatic data to be joined [**MUST CONTAIN UIDS**]

When running a facility-based analysis:
* PEPFAR facility shapefile [Correctly Projected]
* Programmatic data to be joined [**MUST CONTAIN UIDS**]
* Optional: OU polygon data [Not needed if using OSM basemap]

*If you do not have access to OU polygon or PEPFAR facility shapefiles, it may be requested from your GIS Cluster representative.* 

Please remember that the scripts are built using UIDs to join datasets. If your programmatic dataset does not have UIDs, please reach out to the GIS cluster with assistance on creating a spatially enabled table.

This script can only be run one column at a time in its current form. Please organize programmatic data tables accordingly. These columns can be a raw number value such as TX_CURR or a metric using several MER indicators. 

<br><br/>

# RESULTS EXPLAINATION (WHAT AM I LOOKING AT?)

If the script has been run correctly, users will be presented with a final output shapefile, excel table, and an leaflet-based online map of the results. 

Each form of data will contain: 

* **Z-Scores:** For statistically significant positive z-scores, the larger the z-score is, the more intense the clustering of high values (hot spot). For statistically significant negative z-scores, the smaller the z-score is, the more intense the clustering of low values (cold spot).

* **P-Values:** The probability that the observed spatial pattern was created by some random process. When the p-value is very small, it means it is very unlikely (small probability) that the observed spatial pattern is the result of random processes, so you can reject the null hypothesis.

* **Hot Spot Score:** A combination of Z-Scores and P-Values used to make it easier to interpret the results. We have recategorized these as simple numbers to enable their use within other platforms. Refer to the script for more information on how these categories are created.
    * **-3**  =  99% Confidence Coldspot 
    * **-2**  =  95% Confidence Coldspot
    * **-1**  =  90% Confidence Coldspot 
    * **0**  =  Not Significant 
    * **1**  =  99% Confidence Hotspot 
    * **2**  =  95% Confidence Hotspot
    * **3**  =  90% Confidence Hotspot 

Remember that a hot spot analysis is not the same as a heat map. When conducting a hot spot analysis, users are trying to determine if there are any statistically significant spatial clustering of data.

<br><br/>

# WHY ARE MY RESULTS DIFFERENT?

One of the most common questions asked is some form of: Why are my results different than the hot spot analysis run by [X] software? The simplest answer is that different software handle numbers and spatial data in different ways. The difference in outputs can also come down to user defined thresholds. While the main objective of a hot spot analysis is to lower subjectivity, there are instances where adjusted model parameters can affect results. Please note that due to the intended audience of this script, much of the parameters are outside of the users’ control. 
