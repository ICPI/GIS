### **[Click HERE for a direct link to the script](https://github.com/ICPI/GIS/blob/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/GetisOrd_HS_Analysis_Facility_Template.R)**

<br><br/>
<br><br/>

# FACILITY SCRIPT BREAKDOWN: 

For this walkthrough, dummy data within Ethiopia was used. Your results will differ. 

<br><br/>

**SECTION 1: SETTING UP THE SCRIPT**

![](https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/SECTION%201.png)

This section is mostly straightforward. Install/import the required libraries to execute this tool. Please set your working directory to save all the various outputs. Please place all programmatic data tables and PEPFAR shapefiles within this folder.

<br><br/>
<br><br/>

**SECTION 2: IMPORT THE DATA**

![](https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/SECTION%202.png)

In this section we will be importing our datasets.

<span style="text-decoration: underline"> 1.) Load OU Health Facilities Shapefile </span>

```
Fac <- readOGR("shapefilename.shp")
```
“Fac” will be the script name for our facility data. This data will also appear in the top right Environments, if using R Studio. If the shapefiles are saved within your working directory, you may simply call it by name as in the example. If it is saved elsewhere please use the full pathname, remembering to used double backslashes ( \\\  )

```
names(Fac)
crs(Fac)
```
[Optional] code to check that the shapefile was imported corrected and projected. In this example, when running ‘crs’ to verify projections, Ethiopia shows as:  
* +proj=utm +zone=37 +datum=WGS84 +units=m +no_defs

Be sure that the shapefile displays any coordinate system except the below: 
* +proj=longlat +datum=WGS84 +no_defs

If it is only WGS84, the data needs to be reprojected.  If you would like to verify the geometry of the sites, plot(Fac) can also be run at this point.

<br><br/>

<span style="text-decoration: underline"> 2) Load OU Programmatic Dataset </span>

```
PData <- read.csv("programtable.csv")
```

“PData” will be the script name for our programmatic data. Your pre-made program data will need to be saved as a CSV. 

```
names(PData)
```

An [optional] check.

To see an example of how a table could be organized, see the image below. Note that this tool will have to be run twice, once for the hot spot analysis based on the metrics and another for the raw number column.

![](https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/ExampleTable.png)

<br><br/>

<span style="text-decoration: underline"> 3) Merge Datasets based on UID </span>

```
MData <- merge(x=Fac, y=PData, 
               by.x="uid", by.y="uid", all.x=FALSE)
```
“MData” will be the script name for our merged dataset. As previously mentioned, the tables will be joined based on PEPFAR UID columns. Change the “uid” as needed to match the columns within your datasets. Common variations include “fac_uid”, “UID”, “orguid”, etc. If you forgot exact column labels, please use the *names()* function or click on the datasets in the *Environments* menu (if using R Studio). 

```
summary(MData)
class(MData)
crs(MData)
```
More [optional] lines of code to check your merged dataset. 

<br><br/>
<br><br/>

**SECTION 3: HOT SPOT ANALYSIS**

![](https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/SECTION%203.png)

This section should be mostly automatic, with minor user changes needed. The section begins by gathering distance information based on the dataset’s geographic distribution. Once those calculations are completed, the hot spot analysis is executed and Z-Scores are created. Once we have Z-Scores, we then calculate P-Values and rename the column to be more human friendly. 

<br><br/>

<span style="text-decoration: underline"> 1) Neighborhood Connectivity (ANN): In this step users will create a series of datasets that measure the average distance from each point within the study area to its nearest point. </span>

```
ptdist=pointDistance(MData)
```
Using the merged dataset (MData), create a straight line point distance matrix. The file will look something like this:

![](https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/PTDIST.png)

```
min.dist<-min(ptdist);
```
Using the point distance matrix (ptdist), determine the minimum distance between points. Based on most coordinate systems, this number will be in meters. The exact number will appear in *Environments* (if using R Studio) for quick reference. For this example, Ethiopia’s lowest distance is 0 meters, likely due to overlapping health facilities. This value will be referred to as “min.dist” within the script. 

```
q10.dist<-as.numeric(quantile(ptdist,probs=0.10)); 
```
Using the point distance matrix (ptdist), use the *as.numeric()* function to get the lower 10% of a quantile distribution. For this example, Ethiopia is a large country so the value is approximately 130km. While 0.10 is the standard calculation, this in an instance where user parameters can affect the final output. For instance, if I believed that 130km is too large of a catchment area for each facility, I might run *probs=0.25* or *0.50* to get create a catchment area closer to 50km. There is not correct answer and is highly dependent on the geographical distribution of the points. It may be worth running the analysis more than once and compare results. This value will be referred to as “q10.dist” within the script. If using a value other than *0.10*, it may be helpful to rename this value. 

```
nb<-dnearneigh(coordinates(MData),min.dist,q10.dist) 
```
Using our merged dataset (MData), minimum distance (min.dist) value, and quantile distance (q10.dist), identify neighbors of region points by straight line distance between lower and upper bounds. This neighborhood matrix will be referred to as simply “nb”  within the script.

<br><br/>

<span style="text-decoration: underline"> 2) Local-G: Creating Z-Scores (local Getis-Ord analysis) </span>

```
nb_lw<-nb2listw(nb, zero.policy = TRUE)
```

Add a spatial weight matrix to the neighborhood data (nb) that was just calculated. This appended matrix will be referred to as “nb_lw”.

```
loc_g<-localG(MData@data$Value, nb_lw)
```
Run the local Getis-Ord analysis using our latest matrix dataset (nb_lw). The results will be saved as “log_g”.

Please replace Value with the appropriate column name. For instance, in the example table's column names, if the hotspot analysis was for the derived metric, we would use 
```
MData@data$Derived_Metric
```
<br><br/>

<span style="text-decoration: underline"> 3) Convert to Matrix </span>

<span style="text-decoration: underline"> 4) Column-Bind the Local_G Data </span>

```
loc_g.ma=as.matrix(loc_g)
HSData<-cbind(MData,loc_g.ma)
```
These next two steps are straightforward. Using the local Getis-Ord output (loc_g), convert to a matrix and column bind the data. The final form will be called “HSData”

<br><br/>

<span style="text-decoration: underline"> 5) Adjust Column Names </span>

```
names(HSData)[ncol(HSData)]="Zscore"
names(HSData)
```

Create a new column for Z-Scores and use the *names()* function to verify that it was created correctly. 

<br><br/>

<span style="text-decoration: underline"> 6) Creating P-Values from Z-Scores </span>

```
HSData$pvalue<- 2*pnorm(-abs(HSData$Zscore))
names(HSData)
```
Calculate P-Values based on the Z-Scores using the standard calculation provided. Using the *names()* function, ensure that both Z-Scores and P-Values are within your dataset. 

<br><br/>
<br><br/>

**[OPTIONAL] SECTION: CHECK OUTPUTS**

```
# Number of Hot Spots

# 99% Confidence
subset(HSData@data,Zscore>=2.58&pvalue<=0.01)$facility 

# 95% Confidence
subset(HSData@data,Zscore>=1.96&Zscore<2.58&pvalue>0.01&pvalue<=0.05)$facility 

# 90% Confidence
subset(HSData@data,Zscore>=1.65&Zscore<1.96&pvalue>0.05&pvalue<=0.1)$facility 

# Number of Cold Spots

# 99% Confidence
subset(HSData@data,Zscore<=-2.58&pvalue<=0.01)$facility

# 95% Confidence
subset(HSData@data,Zscore<=-1.96&Zscore>-2.58&pvalue>0.01&pvalue<=0.05)$facility

# 90% Confidence
subset(HSData@data,Zscore<=-1.65&Zscore>-1.96&pvalue>0.05&pvalue<=0.1)$facility
```

In this optional step, you can quickly check cold and hot spots within the R Studio console. Change **facility** to match the column name for facilities within your dataset. Use the *names()* or *head() *function for assistance.

<br><br/>
<br><br/>

**SECTION 4: RECLASSIFYING THE HOT SPOT DATA**

![](https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/SECTION%204.png)

In this section we will clean up the data to only keep the needed information. We will also create hot spot scores based on standard classifications of Z-Scores and P-Values. The hot spot scores will range from -3 to 3. This will make the data easier to display in other platforms. 

```
names(HSData)
```
To begin with, run the *names()* function to see all the columns within your hot spot dataset (HSData). 

```
HSData@data <- HSData@data %>% 
  dplyr::select(level3, level4, level5, level6, level7, uid, derived_metric, Zscore, pvalue, LONG, LAT) %>%
  #Optional Step, based on results from names(shapefile)
  #rename(level3 = level3name.x,
         #level4 = level4name.x,
         #level5 = level5name.x) %>%
```
The minimum amount of columns you want to keep:
* All the locational information starting from country name (level 3) down to facility level (typically around level 7)
* UIDs
* The column used for analysis (in this example it’s the derived_metric column)
* Z-Scores
* P-Values
* Lat/Long coordinates

The hidden [optional] step are for users who want to use this step to rename columns within their curated dataset.

```
mutate(HS_Output = case_when(HSData@data$Zscore <= -2.58 & HSData@data$pvalue <= 0.01 ~ -3,
                               HSData@data$Zscore <= -1.96 & HSData@data$Zscore > -2.58 & HSData@data$pvalue <= 0.05 & HSData@data$pvalue > 0.01 ~ 2,
                               HSData@data$Zscore <= -1.65 & HSData@data$Zscore > -1.96 & HSData@data$pvalue <= 0.1 & HSData@data$pvalue > 0.05 ~ 1,
                               HSData@data$Zscore > -1.65 & HSData@data$Zscore < 1.65 & HSData@data$pvalue > 0.1 ~ 0,
                               HSData@data$Zscore >= 1.65 & HSData@data$Zscore < 1.96 & HSData@data$pvalue <= 0.1 & HSData@data$pvalue > 0.05 ~ 1,
                               HSData@data$Zscore >= 1.96 & HSData@data$Zscore < 2.58 & HSData@data$pvalue <= 0.05 & HSData@data$pvalue > 0.01 ~ 2,
                               HSData@data$Zscore >= 2.58 & HSData@data$pvalue <= 0.01 ~ 3))
```
This step creates a hot spot column (HS_Output) and populates it with the aforementioned number range. 

```
names(HSData@data)
head(HSData@data)
class(HSData)
```
[Optional] lines of code to verify results. 

<br><br/>
<br><br/>

**SECTION 5: EXPORTING THE DATA**

![](https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/SECTION%205.png)

```
# Export as a Shapefile
Data_sf <- st_as_sf(HSData)
st_write(Data_sf, "OutputShapefileFacility.shp")
# Export as a CSV
write.table(HSData, file="OutputTableFacility.csv",sep=",",row.names=F)
```
Export the data as a shapefile for using in other spatial software. Export the data as a CSV to be used in Excel, BI software, or any other program that uses data tables. Rename these files whatever you prefer.

<br><br/>
<br><br/>

**[OPTIONAL] SECTION: DISPLAYING THE DATA USING LEAFLET**

If you would like a map of the data, use the provided leaflet code to quickly visualize your results. The web map can be exported as an html or PNG file if desired. 

<br><br/>

<span style="text-decoration: underline"> 1) Re-import the exported shapefile from **SECTION 5** </span>

```
NHSData <- readOGR("OutputShapefileFacility.shp")
class(NHSData)
crs(NHSData)
```
Add the shapefile exported from SECTION 5. Use the *crs()* function to check its projection. 

<br><br/>

<span style="text-decoration: underline"> [Optional]: Add OU polygon shapefile </span>
```
PSNU <- readOGR("ETH_ZONES.shp")
PSNU <- spTransform(PSNU, 
                        CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
```
Only run this step if you plan to add polygon SNU/PSNU data to the map. If not, comment out this section.

<br><br/>

<span style="text-decoration: underline"> 2) Re-project the shapefile to match Leaflet's default coordinate system </span>

```
crs = leafletCRS()
NHSData <- spTransform(NHSData, 
                        CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
crs(NHSData)
class(NHSData)
head(NHSData)
```
Unlike at the beginning of the script, we want to convert to WGS84 web Mercator projection to allow the shapefile to properly display on Leaflet.

<br><br/>

<span style="text-decoration: underline"> 3) Set hotspot breaks/colors </span>

```
bins <- c(-3, -2, -1, 0, 1, 2, 3, 4)
pal <- colorBin(c("#1f78b4", "#26bbdb", "#92ffe1", "#fcffdb" ,"#ffb38a", "#fd6e5c", "#b20000"), 
                domain = NHSData$HS_Output, 
                bins = bins)
labels <- c("Coldspot [99% Confidence]", "Coldspot [95% Confidence]", "Coldspot [90% Confidence]", 
            "Not Significant", "Hotspot [90% Confidence]", "Hotspot [95% Confidence]", "Hotspot [99% Confidence]")
```
Creates color breaks and relabels the HS Output scores into something more human readable in the legend.

<br><br/>

<span style="text-decoration: underline"> 4) Add layers to map </span>

This section is where we set the map parameters. While it is all connected, we will break down each subsection below.

```
map <- leaflet(NHSData) %>% 
```
Begin the map function

```
  # Add Basemap + Set Layer Visual Layer
  addTiles() %>%
  addMapPane("Facilities", zIndex = 430) %>% 
  addMapPane("PSNU", zIndex = 420) %>%
```
This section adds our [optional] basemap and sets the visual heirachy of the map. If you do not want to add the OSM Basemap you can comment out **addTiles() %>%**. If you would like to exclude polygon data, you may comment out **addMapPane("PSNU", zIndex = 420) %>%**

```
# Add Facility Data
  addCircles(
    data = NHSData,
    lng = ~LONG,
    lat = ~LAT,
    weight = 1,
    radius = 10000,
    color = "white",
    fillOpacity = .75,
    fillColor =  ~pal(HS_Output),
    popup = paste0('<strong>', "PSNU:  ", '</strong>', NHSData$level5,
                  "<br>",
                  '<strong>', "Facility:  ", '</strong>', NHSData$level7,
                  "<br>", 
                  '<strong>', "Hotspot Score:  ", '</strong>', NHSData$HS_Output),
    highlight = highlightOptions(weight = 3,
                                 color = 'white',
                                 fillOpacity = 0.5,
                                 bringToFront = TRUE),
    label = ~level5,
    group = 'Facilities',
    options = pathOptions(pane = "Facilities")) %>%
```
In this section we add the facility level data and set an appropriate cartographic style. Some notes:

* **lng/lat** - change the ~LONG/~LAT values to match your data's column names for coordinates. Common deviations include: "Latitude", "longitude", "lat","OU_long", etc.
* **level5/level7** - change the $level5/$level7 values to match your data's column names for facilities and PSNU.

```
# [Optional Add PSNU data]
  addPolygons(
    data = PSNU,
    fillColor = "#D3D3D3",
    fillOpacity = 0.75,
    weight = 1,
    color = 'white',
    group = 'PSNU',
    options = pathOptions(pane = "PSNU"),
    label = ~level5name) %>%
```

If adding polygon SNU/PSNU data, run this code and adjust the **~level5name** value accordingly.

```
# Add layer control panel
  addLayersControl(
    overlayGroups = c("Facilities", "PSNU"),
    #baseGroups = c("OSM (default)"),
    options = layersControlOptions(collapsed = TRUE)
    ) %>%
```

Adds a layer control panel in the top right of the map. 

```
# Add legend
  addLegend(
    pal = pal,
    values = ~pal(HS_Output),
    title = "Hotspot Results",
    position = "topright",
    labFormat = function(type, cuts, p) {
      paste0(labels)}) %>%
```
Adds a legend to the top right of the map, below layer control. You may change placement to "bottomright", "bottomleft, or "topleft". The title can also be adjusted to better reflect your data.

```
# Add scale bar
  addScaleBar(
    position = "bottomleft"
  )
```
Adds a scalebar to the bottom left of the map. You may change the placement to "bottomright", "topright, or "topleft"

<br><br/>

<span style="text-decoration: underline"> 5) Show Map </span>
```
map
```

Display the map.

<br><br/>
<br><br/>

**SUMMARY SECTION: COMPARING THE OUTPUT TO QGIS ANALYSIS**

R LEAFLET OUTPUT:

![](https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/R.Fac.Leaflet.png)

QGIS OUTPUT:

![](https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/QGIS.HS.png)