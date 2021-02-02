# authored by Anubhuti Mishra, CDC/DDPHSIS/CGH/DGHT 

library(tidyverse)
library(data.table)
library(readxl)
library(rgdal)
library(rgeos)
library(sp)
library(leaflet)
library(maptools)
library(RColorBrewer)
library(htmltools) 
library(htmlwidgets)
library(crosstalk)library
# library(minicharts)
library(haven) 
library(scales)
#install.packages("geosphere") 
library(geosphere)
library(eply)
library(REdaS)
library(janitor)
library(tools)
library(openxlsx)



# MER TX_CURR DATA -----

#Import Q2 2019 MSD
msd <- fread("Nigeria_site_im_tx_curr_20_q1.txt", stringsAsFactors=FALSE)

saveRDS(msd, 'ng_site_im.rds')
#import facility Lat. Long. data
#library(readxl)
fl_lat_lng <- read_excel("~/HETA/Work Experience/Technical/Project 2 Linkage/Data Input/Lat. Long. Nigeria_FacilityReport_2018.xlsx", 
                         sheet = "Nigeria_FacilityAudit_20190114", 
                         range = "A1:AA8001", na = "0")

ng_site_im <- readRDS("ng_site_im.rds")
fl_lat_lng <- readRDS("Lat_Long_Nigeria_FacilityReport_2018.rds")
Nigeria_State_LGA <- readRDS("Nigeria_State_LGA.rds")
Nigeria_State_shp <- readRDS("Nigeria_State_shp.rds")


#pulling shape files; specidy file path and the layer;----
#Always use the lowest unit of shape files available for the algorithm

Nigeria_State_LGA <- readOGR(dsn='C:/Users/lny8/Documents/HETA/Work Experience/Technical/Project 2 Linkage/Data Input/Nigeria_LGA_2017_Mar', layer = 'Nigeria_PROD_5_LGA_LocalGovernmentAreaLsib_2017_Mar')

#validate the shape----
#plot(Nigeria_State_LGA)

fl_tx_curr <- ng_site_im %>% 
  filter(indicator %in% c("TX_CURR")) %>% 
  gather(Qtr,value, Qtr1:Qtr4) %>% 
  filter(!is.na(value)) %>% 
  filter(Fiscal_Year %in% c("2019")) %>% 
  filter(standardizedDisaggregate %in% c("Total Numerator"), Qtr=="Qtr2") %>% 
  filter(SNU1!="_Military Nigeria") %>% 
  filter(SNU1!=" ") %>% 
  group_by(PSNU,PSNUuid,FacilityUID,Facility,indicator,Fiscal_Year, Qtr,value) %>% 
  #always remove NA using na.rm when you summarize
  summarise(FY19Q2=sum(value,na.rm=TRUE)) %>% 
  ungroup() %>%  
  select(-value,-Fiscal_Year, -Qtr) %>% 
  filter(!is.na(Facility))

psnu_tx_curr<-fl_tx_curr %>% 
  group_by(PSNU,PSNUuid,indicator) %>% 
  summarise(FY19Q2=sum(FY19Q2, na.rm=TRUE)) %>% 
  ungroup()

#merge data in psnu TX_CURR to LGA shape files. use merge fucntion to join spatial object to data frame
psnu_shp_tx_curr <- merge(Nigeria_State_LGA,psnu_tx_curr, by.x='uid', by.y ='PSNUuid')

# select variables of interest from LGA lat long data frame
fl_lat_lng2 <- fl_lat_lng %>% 
  select(uid,Latitude, Longitude)

#join the facility tx_curr data to the lat lng data frame
fl_tx_curr_coord <- left_join(fl_tx_curr,fl_lat_lng2, by=c("FacilityUID"="uid"))


# create choropleth maps -----
#Load RColorBrewer::color palate tp help you choose sensible colour schemes for figures in R.
#For example if you are making a boxplot with eight boxes, what colours would you use, 
#or if you are drawing six lines on an x-y plot what colours would you use so you can easily 
#distinguish the colours and look them up on a key? RColorBrewer help you to do this. The colors used below
#are ICPI colors. Check for other colors in the package

# library(RColorBrewer)

colfn <- colorRampPalette(c('#335b8e', 
                            '#6ca18f', 
                            '#b5b867',
                            '#cc5234', 
                            '#d9812c', 
                            '#948d79'))(82)

#create a vector to assign color keys by TX_CURR group
legend.labels <- c('0-50', '51-500', '501-5000', '5001-10,000', '>10,000')

# create a bin variable for tx_curr
fl_tx_coord <- fl_tx_curr_coord %>% 
  mutate(tx.bins= cut(fl_tx_curr_coord$FY19Q2, 
                      breaks=c(0,50,500,5000,10000, max(fl_tx_curr_coord$FY19Q2)), 
                      labels = legend.labels))

# see all the colour palette options
#display.brewer.all()

#create colour palette for facilities
fl_pal <- colorFactor(palette = colfn, domain = fl_tx_coord$tx.bins)

# colour palette for psnu
psnu_pal <- colorBin(palette = 'YlOrRd', domain = psnu_shp_tx_curr@data$FY19Q2, bins = 5)

#To add label to psnu polygons
psnu.label <- sprintf(
  "<strong> %s <br/> FY19Q2_TX_CURR: %g",
  psnu_shp_tx_curr$PSNU, psnu_shp_tx_curr$FY19Q2
) %>% lapply(HTML)

#The Leaflet package expects all point, 
#line, and shape data to be specified in latitude and longitude using WGS84
leaflet() %>% 
  #add tile to show the background map
  addTiles() %>% 
# set boundary thickness to 1 and color polygons; use shape file containing the data of interest (tx_curr)
  addPolygons(data=psnu_shp_tx_curr, 
              fillColor=~psnu_pal(psnu_shp_tx_curr@data$FY19Q2),
              color='grey', weight=1, opacity=.7, fillOpacity = 0.5, label = psnu.label) %>% 
  #layer facilities in the facility data frame to the map based on the indicator of interest
  addCircleMarkers(data=fl_tx_coord, lng=~Longitude, lat=~Latitude, radius=1, opacity=1,
                   label=~paste(Facility), color=~fl_pal(tx.bins),
                   labelOptions = labelOptions(noHide = F, direction = 'topright', 
                                               style = list("color" = "blue"))) %>% 
  addLegend('bottomright', pal= fl_pal, values = fl_tx_coord$tx.bins,title = 'Faclity: FY19Q2 TX_CURR') %>% 
  addLegend('bottomleft', pal= psnu_pal, values = psnu_shp_tx_curr@data$FY19Q2,
            title = 'PSNU: FY19Q2 TX_CURR')

# =====================================================================================
# PVLS ======================================================================================
fl_pvls <- ng_site_im %>% 
  filter(indicator %in% c("TX_PVLS")) %>% 
  gather(Qtr,value, Qtr1:Qtr4) %>% 
  filter(!is.na(value)) %>% 
  filter(Fiscal_Year %in% c("2019")) %>% 
  filter(standardizedDisaggregate %in% c("Total Numerator", "Total Denominator"), Qtr=="Qtr2") %>% 
  filter(SNU1!="_Military Nigeria") %>% 
  filter(SNU1!=" ") %>% 
  group_by(PSNU,PSNUuid,FacilityUID,Facility,standardizedDisaggregate,indicator,Fiscal_Year, Qtr,value) %>% 
  #always remove NA using na.rm when you summarize
  summarise(subtotal=sum(value,na.rm=TRUE)) %>% 
  ungroup() %>%  
  select(-value,-Fiscal_Year, -Qtr) %>% 
  filter(!is.na(Facility)) %>% 
  group_by_at(vars(PSNU:indicator)) %>% 
  summarise(subtotal=sum(subtotal,na.rm=TRUE)) %>% 
  spread(standardizedDisaggregate, subtotal) %>% 
  ungroup() %>% 
  mutate(PVLS=round(((`Total Numerator`/`Total Denominator`)*100),digits=0)) %>% 
  select(-indicator) %>% 
  filter(PVLS!="NaN")
  
#LGA PVLS; group facility pvls into LGA
psnu_pvls<-fl_pvls %>% 
  group_by(PSNU, PSNUuid) %>% 
  summarise_at(vars(`Total Denominator`:PVLS), sum, na.rm=T) %>% 
  ungroup() %>% 
  mutate(PVLS=round(((`Total Numerator`/`Total Denominator`)*100),digits=0))
  
#merge data in psnu PVLS to LGA shape files. use merge fucntion to join spatial object to data frame
psnu_shp_pvls <-merge(Nigeria_State_LGA, psnu_pvls, by.x='uid', by.y='PSNUuid')

# select variables of interest from LGA lat long data frame
fl_lat_lng2 <- fl_lat_lng %>% 
  select(uid,Latitude, Longitude)

#join the facility tx_curr data to the lat lng data frame
fl_tx_pvls_coord <- left_join(fl_pvls,fl_lat_lng2, by=c("FacilityUID"="uid")) %>% 
  filter(!is.na(Latitude)) 


#Load RColorBrewer::color palate tp help you choose sensible colour schemes for figures in R.
#For example if you are making a boxplot with eight boxes, what colours would you use, 
#or if you are drawing six lines on an x-y plot what colours would you use so you can easily 
#distinguish the colours and look them up on a key? RColorBrewer help you to do this. The colors used below
#are ICPI colors. Check for other colors in the package

# library(RColorBrewer)

colfn <- colorRampPalette(c('#335b8e', 
                            '#6ca18f', 
                            '#b5b867',
                            '#cc5234', 
                            '#d9812c', 
                            '#948d79'))(82)

#create a vector to assign color keys by TX_CURR group
legend.labels <- c('0-50', '51-70', '71-80', '81-90', '>90')

# create a bin variable for tx_curr
fl_pvls_coord <- fl_tx_pvls_coord %>% 
  mutate(tx.bins= cut(fl_tx_pvls_coord$PVLS, 
                      breaks=c(0,50,70,80,90,100), 
                      labels = legend.labels))

# see all the colour palette options
#display.brewer.all()

#create colour palette for facilities
fl_pal_pvls <- colorFactor(palette = colfn, domain = fl_pvls_coord$tx.bins)

# colour palette for psnu
psnu_pal_pvls <- colorBin(palette = 'RdYlGn', domain = psnu_shp_pvls@data$PVLS, bins = 5)

#To add label to psnu polygons
psnu.label <- sprintf(
  "<strong> %s <br/> FY19Q2_TX_PVLS: %g",
  psnu_shp_pvls$PSNU, psnu_shp_pvls$PVLS
) %>% lapply(HTML)



#The Leaflet package expects all point, 
#line, and shape data to be specified in latitude and longitude using WGS84
leaflet() %>% 
  #add tile to show the background map
  addTiles() %>% 
  # set boundary thickness to 1 and color polygons; use shape file containing the data of interest (tx_curr)
  addPolygons(data=psnu_shp_pvls, 
              fillColor=~psnu_pal_pvls(psnu_shp_pvls@data$PVLS),
              color='grey', weight=1, opacity=.7, fillOpacity = 0.5, label = psnu.label) %>% 
  #layer facilities in the facility data frame to the map based on the indicator of interest
  addCircleMarkers(data=fl_pvls_coord, lng=~Longitude, lat=~Latitude, radius=3, opacity=20,
                   label=~paste(Facility), color=~fl_pal_pvls(tx.bins),
                   labelOptions = labelOptions(noHide = F, direction = 'topright', 
                                               style = list("color" = "purple"))) %>% 
  addLegend('bottomright', pal= fl_pal_pvls, values = fl_pvls_coord$tx.bins,title = 'Faclity: FY19Q2 TX_PVLS') %>% 
  addLegend('bottomleft', pal= psnu_pal_pvls, values = psnu_shp_pvls@data$PVLS,
            title = 'PSNU: FY19Q2 TX_PVLS')


# create map to show network for small and large facilities ----
# filter facilities with 0-50 patients 

small.fac <- fl_tx_coord %>% filter(FY19Q2 <= 50) %>% 
  select(PSNU,FacilityUID, Facility, FY19Q2, Latitude, Longitude) %>% 
  rename(TX_CURR_FY19Q2 = FY19Q2)

large.fac <- fl_tx_coord %>% filter(FY19Q2 > 50)%>% 
  select(FacilityUID, Facility, FY19Q2, Latitude, Longitude) %>%  
  rename(lat_2=Latitude, lng_2=Longitude, TX_CURR_FY19Q2 = FY19Q2)


dist.matt <- merge(x=small.fac, y = large.fac, by=NULL)

# create distance matrix between sites <=50 and >50 patients and then filter for the closest >50 site for each
dist.mat <- dist.matt %>% 
  mutate(distance = distHaversine(cbind(Longitude, Latitude), cbind(lng_2, lat_2))) %>% 
  mutate(distance = round(distance*0.001,1)) %>%
  arrange(FacilityUID.x, distance) %>% 
  #subset for only dydads within top 100 of rank distance
  group_by(FacilityUID.x) %>% 
  mutate(rank_d = row_number()) %>% 
  ungroup() %>% 
  filter(rank_d==1)  %>% 
  filter_all(all_vars(!is.na(.)))


# #To add label to facility markers
small.fac.label <- sprintf(
  "<strong> %s <br/> FY19Q2_TX_CURR: %g",
  dist.mat$Facility.x, dist.mat$TX_CURR_FY19Q2.x
) %>% lapply(HTML)

large.fac.label <- sprintf(
  "<strong> %s <br/> FY19Q2_TX_CURR: %g",
  dist.mat$Facility.y, dist.mat$TX_CURR_FY19Q2.y
) %>% lapply(HTML)


m <- leaflet() %>% 
  #add tile to show the background map
  addTiles() %>% 
  addPolygons(data=Nigeria_State_shp, fillOpacity = 0, weight = 0.5) %>% 
  addFlows(dist.mat$Longitude, dist.mat$Latitude, dist.mat$lng_2, dist.mat$lat_2,
           flow = dist.mat$distance, popup = popupArgs(labels ="Dist (km)"), dir = 0,
           minThickness = 2, maxThickness = 2, opacity = 0.6, color = '#006633')

# for (i in 1:nrow(dist.mat)) {
#   m <-m %>% 
#   addPolylines(lat=c(dist.mat[i,]$Latitude, dist.mat[i,]$lat_2),lng=c(dist.mat[i,]$Longitude, dist.mat[i,]$lng_2), color = '#006633', opacity = 0.6)
# }

title <- tags$div(HTML("Every small facility is connected to its closest larger facility with a green line"))

m2 <- m %>% 
  #layer facilities in the facility data frame to the map based on the indicator of interest
  addCircleMarkers(data=dist.mat, lng=~Longitude, lat=~Latitude, radius=1, opacity=1,
                   label=small.fac.label, color= '#CC0000',
                   labelOptions = labelOptions(noHide = F, direction = 'topright',
                                               style = list("color" = "purple"))) %>%
  addCircleMarkers(data=dist.mat, lng=~lng_2, lat=~lat_2, radius=1, opacity=1,
                   label=large.fac.label, color= '#000099',
                   labelOptions = labelOptions(noHide = F, direction = 'topright', 
                                               style = list("color" = "purple"))) %>% 
  addLegend("bottomright", colors = c('#CC0000', '#000099'), labels = c('Facilities <= 50 patients', 'Facilities > 50 patients'), opacity = 1) %>% 
  addControl(title, position = 'topright')

m2

htmltools::save_html(m2, 'Nigeria_map_small_to_large_facilities_flows.html')

write.xlsx(dist.mat, 'small_large_facilities_mat.xlsx')




# sites <= 20 patients 




