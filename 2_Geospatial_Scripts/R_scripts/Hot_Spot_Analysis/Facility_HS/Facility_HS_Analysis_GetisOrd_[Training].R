# ------------------------------------------------
# SECTION 1: SETTING UP
# ------------------------------------------------

# 1A) Install Packages (If libraries are already installed, skip to 1B)
install.packages("dplyr")
install.packages("leaflet")
install.packages("knitr")
install.packages("raster")
install.packages("rgdal")
install.packages("rgeos")
install.packages("sf")
install.packages("sp")
install.packages("spdplyr")
install.packages("spdep")

# 1B) Activate Libraries
library(dplyr)
library(leaflet)
library(knitr)
library(raster)
library(rgdal)
library(rgeos)
library(sf)
library(sp)
library(spdplyr)
library(spdep)

knitr::opts_chunk$set(echo = TRUE)
options(prompt="R> ", digits=4, scipen=999)

# 2) Set Working Directory
setwd("C:\\Users\\Downloads\\Hot_Spot_Folder")
##### ___^^^ USER INPUT ^^^___  ######
##### *Change working directory to your folder*  ######
getwd()



# ------------------------------------------------
# SECTION 2: LOAD AND MERGE DATA
# ------------------------------------------------

# 1) Load OU Health Facilities Shapefile
Fac <- readOGR("ETH_Health_Facilities.shp")
##### ___^^^ USER INPUT ^^^___  ######
##### *Change file name*  ######
names(Fac)
crs(Fac)

# 2) Load OU Programmtic Dataset
PData <- read.csv("ETH_HF_Programs.csv")
##### ___^^^ USER INPUT ^^^___  ######
##### *Change file name*  ######
names(PData)

# 3) Merge Datasets based on UID 
MData <- merge(x=Fac, y=PData, 
               by.x="uid", by.y="uid", all.x=FALSE)
##### ___^^^ USER INPUT ^^^___  ######
##### *Change 'uid' to name your table's uid column name, if necessary*  ######
summary(MData)
class(MData)
crs(MData)



# ------------------------------------------------
# SECTION 3: HOTSPOT ANALYSIS
# ------------------------------------------------

# 1) Neighborhood Connectivity (ANN):
# Measures the average distance from each point in the study area to its nearest point.
ptdist=pointDistance(MData)

min.dist<-min(ptdist); # Minimum Distance - Other Options: Mean/Max
q10.dist<-as.numeric(quantile(ptdist,probs=0.10)); #Q10 - Output depends on CRS. For this example it is meters.

nb<-dnearneigh(coordinates(MData),min.dist,q10.dist)


# 2) Local-G: Creating Z-Scores
nb_lw<-nb2listw(nb, zero.policy = TRUE)
loc_g<-localG(MData@data$TLD_PERC, nb_lw)
##### ___^^^ USER INPUT ^^^___  ######
##### *Change 'TLD_PERC' to your hot spot metric*  ######

# 3) Convert to Matrix
loc_g.ma=as.matrix(loc_g)


# 4) Column-Bind the Local_G Data
HSData<-cbind(MData,loc_g.ma)


# 5) Adjust Column Names
names(HSData)[ncol(HSData)]="Zscore"
names(HSData)


# 6) Creating P-Values from Z-Scores
HSData$pvalue<- 2*pnorm(-abs(HSData$Zscore))
names(HSData)



# ------------------------------------------------
# [OPTIONAL] SECTION: QUICK CHECK OUTPUTS
# ------------------------------------------------

# Number of Hot Spots
subset(HSData@data,Zscore>=2.58&pvalue<=0.01)$Site.x # 99% Confidence
subset(HSData@data,Zscore>=1.96&Zscore<2.58&pvalue>0.01&pvalue<=0.05)$Site.x # 95% Confidence
subset(HSData@data,Zscore>=1.65&Zscore<1.96&pvalue>0.05&pvalue<=0.1)$Site.x # 90% Confidence
##### ___^^^ USER INPUT ^^^___  ######
##### *Change 'Site.x' to match your facility level column. Run names(HSData) if you do not remember column names*  ######

# Number of Cold Spots
subset(HSData@data,Zscore<=-2.58&pvalue<=0.01)$Site.x # 99% Confidence
subset(HSData@data,Zscore<=-1.96&Zscore>-2.58&pvalue>0.01&pvalue<=0.05)$Site.x # 95% Confidence
subset(HSData@data,Zscore<=-1.65&Zscore>-1.96&pvalue>0.05&pvalue<=0.1)$Site.x # 90% Confidence
##### ___^^^ USER INPUT ^^^___  ######
##### *Change 'Site.x' to match your facility level column. Run names(HSData) if you do not remember column names*  ######



# ------------------------------------------------
# SECTION 4: RECLASSIFYING THE HOT SPOT DATA 
# ------------------------------------------------
names(HSData)
HSData@data <- HSData@data %>% 
  
  # For Older Versions of R, Remove "dplyr::select"
  dplyr::select(level3, level4, level5, level6, Site = Site.x, uid, LAT = LAT.x, LONG = LONG.x, Zscore, pvalue) %>%
  ##### ___^^^ USER INPUT ^^^___  ######
  ##### *Change column names to match your dataset. At a minimum, keep geographic levels, uid, Z-Scores, P-Values, and Lat/Long*  ######

  # Classify results into -3 to 3, based on standardized hot spot rules
  mutate(HS_Output = case_when(HSData@data$Zscore <= -2.58 & HSData@data$pvalue <= 0.01 ~ -3,
                               (HSData@data$Zscore <= -1.96 & HSData@data$Zscore > -2.58) & (HSData@data$pvalue <= 0.05 & HSData@data$pvalue > 0.01) ~ -2,
                               (HSData@data$Zscore <= -1.65 & HSData@data$Zscore > -1.96) & (HSData@data$pvalue <= 0.1 & HSData@data$pvalue > 0.05) ~ -1,
                               (HSData@data$Zscore > -1.65 & HSData@data$Zscore < 1.65) & (HSData@data$pvalue > 0.1) ~ 0,
                               (HSData@data$Zscore >= 1.65 & HSData@data$Zscore < 1.96) & (HSData@data$pvalue <= 0.1 & HSData@data$pvalue > 0.05) ~ 1,
                               (HSData@data$Zscore >= 1.96 & HSData@data$Zscore < 2.58) & (HSData@data$pvalue <= 0.05 & HSData@data$pvalue > 0.01) ~ 2,
                               HSData@data$Zscore >= 2.58 & HSData@data$pvalue <= 0.01 ~ 3))


names(HSData@data)
head(HSData@data)
class(HSData)



# ------------------------------------------------
# SECTION 5: EXPORTING THE DATA
# ------------------------------------------------

# Export as a Shapefile
Data_sf <- st_as_sf(HSData)
st_write(Data_sf, "OutputShapefileFacility.shp")
##### ___^^^ USER INPUT ^^^___  ######
##### *Change file name. If planning to run this tool multiple times, rename based on metric used for this iteration*  ######

# Export as a CSV
write.table(HSData, file="OutputTableFacility.csv",sep=",",row.names=F)
##### ___^^^ USER INPUT ^^^___  ######
##### *Change file name. If planning to run this tool multiple times, rename based on metric used for this iteration*  ######



# ------------------------------------------------
# [OPTIONAL] SECTION: DISPLAYING THE DATA USING LEAFLET
# ------------------------------------------------

# 1) Re-import the exported shapefile from SECTION 5
NHSData <- readOGR("OutputShapefileFacility.shp")
##### ___^^^ USER INPUT ^^^___  ######
##### *Change file name*  ######
crs(NHSData)

# 2) Re-project the shapefile to match Leaflet's default coordinate system
crs = leafletCRS()
NHSData <- spTransform(NHSData, 
                       CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
crs(NHSData)
head(NHSData)

# [Optional]: Add OU polygon shapefile
PSNU <- readOGR("ETH_PSNU_Zones.shp")
##### ___^^^ USER INPUT ^^^___  ######
##### *Change file name*  ######
PSNU <- spTransform(PSNU, 
                    CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
crs(PSNU)

# 3) Set hotspot breaks/colors
bins <- c(-3, -2, -1, 0, 1, 2, 3, 4)
pal <- colorBin(c("#1f78b4", "#26bbdb", "#92ffe1", "#fcffdb" ,"#ffb38a", "#fd6e5c", "#b20000"), 
                domain = NHSData$HS_Output, 
                bins = bins)
labels <- c("Coldspot [99% Confidence]", "Coldspot [95% Confidence]", "Coldspot [90% Confidence]", 
            "Not Significant", "Hotspot [90% Confidence]", "Hotspot [95% Confidence]", "Hotspot [99% Confidence]")

# 4) Add layers to map
map <- leaflet(NHSData) %>% 
  
  # Add Basemap
  addTiles() %>% # Comment out this line if you do not want an OpenStreetMap basemap
  addMapPane("Facilities", zIndex = 430) %>% 
  addMapPane("PSNU", zIndex = 420) %>% 
  
  # Add Facility Data
  addCircles(
    data = NHSData,
    lng = ~LONG,
    lat = ~LAT,
    radius = 10000,
    weight = 1,
    color = "white",
    fillOpacity = 0.75,
    fillColor =  ~pal(HS_Output),
    popup = paste0('<strong>', "PSNU:  ", '</strong>', NHSData$level5, ##### USER INPUT: Change 'level5' to match your PSNU name data column  ######
                   "<br>",
                   '<strong>', "Facility:  ", '</strong>', NHSData$Site, ##### USER INPUT: Change 'Site' to match your Facility name data column  ######
                   "<br>", 
                   '<strong>', "Hotspot Score:  ", '</strong>', NHSData$HS_Output),
    highlight = highlightOptions(weight = 3,
                                 color = 'white',
                                 fillOpacity = 0.5,
                                 bringToFront = TRUE),
    label = ~level5, ##### USER INPUT: Change 'level5' to match your PSNU name data column  ######
    group = 'Facilities',
    options = pathOptions(pane = "Facilities")) %>%
  
  # [Optional Add PSNU data]
  addPolygons(
    data = PSNU,
    fillColor = "#D3D3D3",
    fillOpacity = 0.75,
    weight = 1,
    color = 'white',
    group = 'PSNU',
    options = pathOptions(pane = "PSNU"),
    label = ~level5) %>% ##### USER INPUT: Change 'level5' to match your PSNU name data column  ######
  
  # Add layer control panel
  addLayersControl(
    overlayGroups = c("Facilities", "PSNU"),
    options = layersControlOptions(collapsed = TRUE)
  ) %>%
  
  # Add legend
  addLegend(
    pal = pal,
    values = ~pal(HS_Output),
    title = "Hotspot Results",
    position = "topright",
    labFormat = function(type, cuts, p) {
      paste0(labels)}) %>%
  
  # Add scale bar
  addScaleBar(
    position = "bottomleft"
  )

# 5) Show Map
map
