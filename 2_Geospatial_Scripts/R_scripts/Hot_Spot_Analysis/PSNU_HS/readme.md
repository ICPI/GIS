<h2>
<p align="center">
  <strong><a href="https://github.com/ICPI/GIS/blob/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/PSNU_HS/GetisOrd_HS_Analysis_Polygon_Template.R">[PSNU] Hotspot Script Direct Link</a></strong>
</p>
</h2>

<br><br/>
<br><br/>

# PSNU SCRIPT BREAKDOWN: 

For this walkthrough, dummy data within Ethiopia was used. Your results will differ. 

<br><br/>

**SECTION 1: SETTING UP THE SCRIPT**

![](https://raw.githubusercontent.com/ICPI/GIS/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis/Facility_HS/images/SECTION%201.png)

This section is mostly straightforward. Install/import the required libraries to execute this tool. Please set your working directory to save all the various outputs. Please place all programmatic data tables and PEPFAR shapefiles within this folder.

<br><br/>
<br><br/>

**SECTION 2: LOAD AND MERGE DATA**

```
# 1) Load PSNU Shapefile
PSNU <- readOGR("shapefilename.shp")
# Check the shapefile
plot(PSNU)
names(PSNU)
crs(PSNU)

# 2) Load OU Programmtic Dataset
PData <- read.csv("programtable.csv")
names(PData)

# 3) Merge Datasets based on UID 
MData <- merge(x=PSNU, y=PData, 
               by.x="uid", by.y="uid", all.x=FALSE)
summary(MData)
class(MData)
crs(MData)
```

Add your programmatic table and PEPFAR PSNU shapefile. Once added they will be merged based on UID. Please adjust the **uid** value accordingly, based on your table's column names. If you need a quick reference, use the *names()* or *head()* function. 

<br><br/>
<br><br/>

**SECTION 3: HOTSPOT ANALYSIS**

```
# Neighborhood Connectivity
nb = spdep :: poly2nb(pl = MData, queen = TRUE)

# Spatial Weights Matrix
swm = spdep :: nb2listw(neighbours = nb)
```
Before a hot spot analysis can be done, a spatial distance matrix and neighborhood connectivity assessment much be executed. 

```
# Local-G (Z-Scores)
loc_g = spdep :: localG(x = MData@data$Value, listw = swm)
loc_g
```
Once you have a spatial weights matrix ("swm"), it can be used to preform a local Getis-Ord hot spot analysis. Please change **$Value** to match the column you want to run the hot spot analysis on. For instance, if I were looking at TX_CURR raw numbers, based on my table, I would write **MData@data$TX_CURR**

```
# 3) Convert to Matrix
loc_g.ma=as.matrix(loc_g)

# 4) Column-Bind the Local_G Data
HSData<-cbind(MData,loc_g.ma)
```
Once the inital analysis has been run we need to create a matrix and bind the results to our dataset.

```
# 5) Adjust Column Names
names(HSData)[ncol(HSData)]="Zscore"
names(HSData)

# 6) Creating P-Values from Z-Scores
HSData$pvalue<- 2*pnorm(-abs(HSData$Zscore))
names(HSData)
```

Change the column name to Z-Scores to make it more clear and use those values to calculate P-Values.

<br><br/>
<br><br/>

**SECTION 4: RECLASSIFYING THE HOT SPOT DATA**
```
head(HSData)
HSData@data <- HSData@data %>% 
  # For Older Versions of R, Remove "dplyr::select"
  dplyr::select(level3name.x, level4name.x, level5name.x, uid, Derived_Metric, Zscore, pvalue) %>%
  # [Optional] Rename the column names if desired
    #rename(level3 = level3name.x,
         #level4 = level4name.x,
         #level5 = level5name.x) %>%
  mutate(HS_Output = case_when(HSData@data$Zscore <= -2.58 & HSData@data$pvalue <= 0.01 ~ -3,
                               HSData@data$Zscore <= -1.96 & HSData@data$Zscore > -2.58 & HSData@data$pvalue <= 0.05 & HSData@data$pvalue > 0.01 ~ 2,
                               HSData@data$Zscore <= -1.65 & HSData@data$Zscore > -1.96 & HSData@data$pvalue <= 0.1 & HSData@data$pvalue > 0.05 ~ 1,
                               HSData@data$Zscore > -1.65 & HSData@data$Zscore < 1.65 & HSData@data$pvalue > 0.1 ~ 0,
                               HSData@data$Zscore >= 1.65 & HSData@data$Zscore < 1.96 & HSData@data$pvalue <= 0.1 & HSData@data$pvalue > 0.05 ~ 1,
                               HSData@data$Zscore >= 1.96 & HSData@data$Zscore < 2.58 & HSData@data$pvalue <= 0.05 & HSData@data$pvalue > 0.01 ~ 2,
                               HSData@data$Zscore >= 2.58 & HSData@data$pvalue <= 0.01 ~ 3))

names(HSData@data)
head(HSData@data)
class(HSData)
```

This step creates a hot spot column (HS_Output) and populates it with the number range described on the [hot spot tool landing page](https://github.com/ICPI/GIS/tree/master/2_Geospatial_Scripts/R_scripts/Hot_Spot_Analysis). The optional step is for users who wish to rename their columns to something easier to read.

<br><br/>
<br><br/>

**SECTION 5: EXPORTING THE DATA**
```
# Export as a Shapefile
Data_sf <- st_as_sf(HSData)
st_write(Data_sf, "OutputShapefile.shp")

# Export as a CSV
write.table(HSData, file="OutputTable.csv",sep=",",row.names=F)
```
Export the data as a shapefile for using in other spatial software. Export the data as a CSV to be used in Excel, BI software, or any other program that uses data tables. Rename these files whatever you prefer.

<br><br/>
<br><br/>

**[OPTIONAL] SECTION: DISPLAYING THE DATA USING LEAFLET**
```
# 1) Re-import the exported shapefile from SECTION 5
NHSData <- readOGR("OutputShapefile.shp")
class(NHSData)
crs(NHSData)

# 2) Re-project the shapefile to match Leaflet's default coordinate system
crs = leafletCRS()
NHSData <- spTransform(NHSData, 
                        CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
crs(NHSData)
class(NHSData)
```
To begin, re-import the shapefile that was just exported in **SECTION 5**. Once loaded into your script, re-project it to WGS84 web mercator.

```
# 3) Set hotspot breaks/colors
bins <- c(-3, -2, -1, 0, 1, 2, 3, 4)
pal <- colorBin(c("#1f78b4", "#26bbdb", "#92ffe1", "#fcffdb" ,"#ffb38a", "#fd6e5c", "#b20000"), domain = NHSData$HS_Output, bins = bins)
labels <- c("Coldspot [99% Confidence]", "Coldspot [95% Confidence]", "Coldspot [90% Confidence]", 
            "Not Significant", "Hotspot [90% Confidence]", "Hotspot [95% Confidence]", "Hotspot [99% Confidence]")
```
Creates color breaks and relabels the HS Output scores into something more human readable in the legend.

<br><br/>

<span style="text-decoration: underline"> SET UP THE MAP </span>

```
# 4) Add layers to map
map <- leaflet(NHSData) %>% 
  # Add Basemap
  #addTiles() %>%
```
This line begins the map function and adds our shapefile. If you wish to have an OSM background, un-comment the **addTiles()** line.

```
# Add PSNU Data
  addPolygons(
    fillColor =  ~pal(HS_Output),
    smoothFactor = 0.2,
    fillOpacity = .50,
    weight = 1,
    opacity = 1,
    color = "white", 
    popup = paste0(
                '<strong>', "SNU:  ", '</strong>', NHSData$level4,
                "<br>",
                '<strong>', "PSNU:  ", '</strong>', NHSData$level5,
                "<br>", 
                '<strong>', "Hotspot Score:  ", '</strong>', NHSData$HS_Output),
    highlight = highlightOptions(weight = 3,
                               color = 'white',
                               fillOpacity = 0.5,
                               bringToFront = TRUE),
    label = ~level5) %>%
```
This section adjusts the color, popup, and opacity of the polygon PSNU data. You can adjust these parameters (or add new ones) as needed.

```
# Add legend
  addLegend(
    pal = pal,
    values = ~HS_Output,
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

<span style="text-decoration: underline">Show Map </span>
```
map
```

Display the map.
