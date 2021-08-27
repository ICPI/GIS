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
library(spdep)

knitr::opts_chunk$set(echo = TRUE)
options(prompt="R> ", digits=4, scipen=999)

# 2) Set Working Directory
setwd("C:\\Users\\folder\\folder_2\\")
getwd()



# ------------------------------------------------
# SECTION 2: LOAD AND MERGE DATA
# ------------------------------------------------

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



# ------------------------------------------------
# SECTION 3: HOTSPOT ANALYSIS
# ------------------------------------------------

# Neighborhood Connectivity
nb = spdep :: poly2nb(pl = MData, queen = TRUE)


# Spatial Weights Matrix
swm = spdep :: nb2listw(neighbours = nb)


# Local-G (Z-Scores)
loc_g = spdep :: localG(x = MData@data$Value, listw = swm)
loc_g


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
# SECTION 4: RECLASSIFYING THE HOT SPOT DATA 
# ------------------------------------------------
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



# ------------------------------------------------
# SECTION 5: EXPORTING THE DATA
# ------------------------------------------------

# Export as a Shapefile
Data_sf <- st_as_sf(HSData)
st_write(Data_sf, "OutputShapefile.shp")

# Export as a CSV
write.table(HSData, file="OutputTable.csv",sep=",",row.names=F)



# ------------------------------------------------
# [OPTIONAL] SECTION: DISPLAYING THE DATA USING LEAFLET
# ------------------------------------------------

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

# 3) Set hotspot breaks/colors
bins <- c(-3, -2, -1, 0, 1, 2, 3, 4)
pal <- colorBin(c("#1f78b4", "#26bbdb", "#92ffe1", "#fcffdb" ,"#ffb38a", "#fd6e5c", "#b20000"), domain = NHSData$HS_Output, bins = bins)
labels <- c("Coldspot [99% Confidence]", "Coldspot [95% Confidence]", "Coldspot [90% Confidence]", 
            "Not Significant", "Hotspot [90% Confidence]", "Hotspot [95% Confidence]", "Hotspot [99% Confidence]")

# 4) Add layers to map
map <- leaflet(NHSData) %>% 
  # Add Basemap
  #addTiles() %>%
  
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
  
  # Add legend
  addLegend(
    pal = pal,
    values = ~HS_Output,
    title = "Hotspot Results",
    position = "topright",
    labFormat = function(type, cuts, p) {
      paste0(labels)}) %>%
  
  # Add scale bar
  addScaleBar(
    position = "bottomleft"
  )

# Show Map
map
