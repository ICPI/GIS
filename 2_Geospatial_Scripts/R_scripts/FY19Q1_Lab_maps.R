# authored by Anubhuti Mishra, CDC/DDPHSIS/CGH/DGHT

library(leaflet)
library(tidyverse)
library(rgdal)
library(ggplot2)
memory.limit(size = 90000000)
library(RColorBrewer)
library(openxlsx)


# read site-im data 
site_im <- readRDS("C:/Users/NME1/Desktop/VL tool/FY19_VL_Tool/site_im.rds")

countries <- c("Malawi","Namibia","South Africa","Uganda","Zambia","Eswatini","South Sudan",
               "Zimbabwe","Ethiopia","Tanzania","Kenya","Mozambique","Rwanda","Ukraine","Haiti",
               "Cote d'Ivoire","Vietnam","Lesotho","Nigeria")

site2 <- site_im %>% filter(OperatingUnit %in% countries) %>% 
  filter(indicator == 'LAB_PTCQI' | (indicator == 'TX_CURR' & standardizedDisaggregate == 'Total Numerator') |
           (indicator == 'TX_PVLS' & standardizedDisaggregate %in% c('Total Numerator', 'Total Denominator')))

saveRDS(site2, 'site_im_lab_maps_Fy19Q1.rds')

site_im_lab_maps <- readRDS("site_im_lab_maps_Fy19Q1.rds")

# Create site-level file for map -----
site.lab <- site_im_lab_maps %>% filter(indicator =='LAB_PTCQI') %>% 
  group_by(OperatingUnit, SNU1Uid, Facility, FacilityUID, indicator, standardizedDisaggregate, categoryOptionComboName, otherDisaggregate) %>% 
  summarise(FY18APR = sum(FY2018APR, na.rm = T)) %>% 
  separate(categoryOptionComboName, c('lab-testing', 'category', 'status'), sep='-', remove=T) %>% 
  separate(category, c('tests.type', 'CQI_PT_POCT'), sep=',', remove=T) %>% 
  select(-`lab-testing`) %>% 
  filter(tests.type == ' HIV Viral Load', Facility != 'N/A',
         FY18APR >0)

# Remove POCT sites
site.lab2 <- site.lab %>% 
  filter(!standardizedDisaggregate %in% c('POCT/PT', 'POCT/CQI', 'POCT/TestVolume')) %>% 
  ungroup()

lab.cqi <- site.lab2 %>% filter(standardizedDisaggregate %in% c('Lab/CQI')) %>% 
  mutate(cqi.status = case_when(
    status == ' Audited and fully accredited' ~ 'Accredited',
    status == ' Audited but not accredited' ~ 'Working towards accreditation',
    status == ' Participate but not audited' ~ 'Enrolled in CQI',
    status == ' Testing with no participation' ~ 'Not enrolled in CQI',
    TRUE ~ 'CQI status not reported'
  )) %>% 
  select(-CQI_PT_POCT, -otherDisaggregate, -FY18APR, -status, -standardizedDisaggregate) %>% 
  group_by_all() %>% 
  summarise() %>% 
  ungroup()


lab.pt <- site.lab2 %>% filter(standardizedDisaggregate %in% c('Lab/PT')) %>% 
  select(-CQI_PT_POCT, -otherDisaggregate, -FY18APR, -standardizedDisaggregate) %>% 
  rename(PT.status=status) %>% 
  group_by_all() %>% 
  summarise() %>% 
  ungroup()

lab.vol <- site.lab2 %>% filter(standardizedDisaggregate %in% c("Lab/TestVolume")) %>% 
  ungroup() %>% 
  select(-CQI_PT_POCT, -otherDisaggregate, -status, -standardizedDisaggregate) %>%
  group_by_at(vars(OperatingUnit:tests.type)) %>% 
  summarise(Test.Volume=sum(FY18APR, na.rm=T)) %>% 
  ungroup()

site.lab.xy <- full_join(lab.pt, lab.vol)
site.lab.xy <- full_join(site.lab.xy, lab.cqi)

# label all NAs in cqi-status column as CQI not reported
site.lab.xy <- site.lab.xy %>% mutate(cqi.status=case_when(
  is.na(cqi.status) ~ "CQI status not reported",
  TRUE ~ as.character(cqi.status)
))

#Pull lat/lng data from facility spatial data
fac_xy <- fac_coords@data

# Merge site-level data with coordinates
site.lab.xy <- left_join(site.lab.xy, fac_xy,by = c('FacilityUID'= 'uid'))
site.lab.xy2 <- site.lab.xy %>% mutate_at(vars(cqi.status), as.factor)


# Check list of labs for each country
tab1 <- site.lab.xy2 %>% group_by(OperatingUnit, Facility) %>% summarise()


# create PSNU level Testing gap indicator ----

psnu.vl <- site_im_lab_maps %>% 
  filter(indicator %in% c('TX_CURR', "TX_PVLS")) %>% 
  group_by(OperatingUnit, SNU1, SNU1Uid, PSNU, PSNUuid, indicator, standardizedDisaggregate) %>% 
  summarise(FY19Q1 = sum(FY2019Q1, na.rm = T), FY18Q3 = sum(FY2018Q3,na.rm = T)) %>% 
  gather( period, val, FY19Q1:FY18Q3) %>%
  mutate(indi_disagg_pd = paste0(indicator,'_', standardizedDisaggregate, '_', period)) %>% 
  spread(indi_disagg_pd, val) %>% 
  ungroup() %>% 
  select(-indicator, -standardizedDisaggregate, -period) %>% 
  group_by(OperatingUnit, SNU1, SNU1Uid, PSNU, PSNUuid) %>% 
  summarise_all(sum, na.rm=T) %>% 
  ungroup() 

psnu.vl2 <- psnu.vl %>% 
  select(-`TX_PVLS_Total Denominator_FY18Q3`, -`TX_PVLS_Total Numerator_FY18Q3`) %>% 
  rowwise() %>% 
  mutate(VL_Testing_Gap = sum(`TX_CURR_Total Numerator_FY18Q3`, -`TX_PVLS_Total Denominator_FY19Q1`, na.rm = T))

snu.mwi <- snu.vl2 %>% filter(OperatingUnit == 'Malawi')

# read all shape files and save them as RDS ----

saveRDS(readOGR('shape-files/Cameroon_HealthDistricts12012016', layer = 'Cameroon_HealthDistricts12012016'), 'shape-files/cameroon_shp.rds')

saveRDS(readOGR('shape-files/CotedIvoireHealthDistrictsLsib2016Dec', layer = 'CotedIvoireHealthDistrictsLsib2016Dec'), 'shape-files/civ_shp.rds')

saveRDS(readOGR('shape-files/DRC_PROD_5_HealthZones_HZLsib_2017_March', layer = 'DRC_PROD_5_HealthZones_HZLsib_2017_March'), 'shape-files/drc_shp.rds')

saveRDS(readOGR('shape-files/EthiopiaZonesLsib2016Nov', layer = 'EthiopiaZonesLsib2016Nov'), 'shape-files/eth_shp.rds')

saveRDS(readOGR('shape-files/Haiti_PROD_5_District_DistrictLsib_2017_May', 
                layer = 'Haiti_PROD_5_District_DistrictLsib_2017_May'), 'shape-files/haiti_shp.rds')

saveRDS(readOGR('shape-files/KenyaCountyLsibSept2016', layer = 'KenyaCountyLsibSept2016'), 'shape-files/kenya_shp.rds')

saveRDS(readOGR('shape-files/Lesotho_PROD_5_CommunityCouncil_CCLsib_2017_Apr', 
                layer = 'Lesotho_PROD_5_CommunityCouncil_CCLsib_2017_Apr'), 'shape-files/lesotho_shp.rds')

saveRDS(readOGR('shape-files/MalawiDistrictLsib2016July', layer = 'MalawiDistrictLsib2016July'), 'shape-files/malawi_shp.rds')

saveRDS(readOGR('shape-files/MozambiqueDistrictLsib2017Feb', layer = 'MozambiqueDistrictsLsib2017Feb'), 'shape-files/moz_shp.rds')

saveRDS(readOGR('shape-files/NamibiaHealthDistrictsLsib2016Dec', layer = 'NamibiaHealthDistrictsLsib2016Dec'), 'shape-files/namibia_shp.rds')

saveRDS(readOGR('shape-files/Nigeria_PROD_5_LGA_LocalGovernmentAreaLsib_2017_Mar', 
                layer = 'Nigeria_PROD_5_LGA_LocalGovernmentAreaLsib_2017_Mar'), 'shape-files/nigeria_shp.rds')

saveRDS(readOGR('shape-files/Rwanda2016Dec_District', layer = 'RwandaDistrict2016Dec'), 'shape-files/rawanda_shp.rds')

saveRDS(readOGR('shape-files/SouthAfricaDistrictLsib2016July', layer = 'SouthAfricaDistrictLsib2016July'), 'shape-files/sa_shp.rds')

saveRDS(readOGR('shape-files/SouthSudan_PROD_5_County_CountyLsib_2017_May', 
                layer = 'SouthSudan_PROD_5_County_CountyLsib_2017_May'), 'shape-files/ssudan_shp.rds')

saveRDS(readOGR('shape-files/Swaziland_PROD_5_Tinkhundla_TinkhundlaLsib_2016_July', 
                layer = 'Swaziland_PROD_5_Tinkhundla_TinkhundlaLsib_2016_July'), 'shape-files/swaziland_shp.rds')

saveRDS(readOGR('shape-files/Tanzania_PROD_5_District_DistrictLsib_2018_Nov', 
                layer = 'Tanzania_PROD_5_District_DistrictLsib_2018_Nov'), 'shape-files/tnz_shp.rds')

saveRDS(readOGR('shape-files/Uganda_PROD_5_District_DistrictLsib_2018_Mar', layer = 'Uganda_PROD_5_District_DistrictLsib_2018_Mar'), 
        'shape-files/uganda_shp.rds')

saveRDS(readOGR('shape-files/UkraineOblastLsib2016Aug9', layer = 'UkraineOblastLsib2016Aug9'), 'shape-files/ukraine_shp.rds')

saveRDS(readOGR('shape-files/Vietnam_PROD_5_District_DistrictDespecializedLsib_2017_Mar', 
                layer = 'Vietnam_PROD_5_District_DistrictDespecializedLsib_2017_Mar'), 'shape-files/vietnam_shp.rds')

saveRDS(readOGR('shape-files/ZambiaDistrictLsib2017Jan', layer = 'ZambiaDistrictLsib2017Jan'), 'shape-files/zambia_shp.rds')

saveRDS(readOGR('shape-files/ZimbabweDistrictLsib2016Sept', layer = 'ZimbabweDistrictLsib2016Sept'), 'shape-files/zimbabwe_shp.rds')


# Create map function and loop ----

colfn <- colorRampPalette(c('#335b8e', 
                            '#6ca18f', 
                            '#b5b867',
                            '#cc5234', 
                            '#d9812c', 
                            '#948d79'))(82)

col_pal <- colorBin(palette = colfn, domain = mwi.shp.msd@data$VL_Testing_Gap)


# Color categories for CQI Status
lab_col <- colorFactor(c('#006400', '#9ACD32', '#FFA500', '#FF0000', '#000000'), domain = 
                         c("Accredited","Working towards accreditation","Enrolled in CQI","Not enrolled in CQI","CQI status not reported"))

# Loop to create all maps at once
for (i in countries) {
  shpx <-  read_rds(paste0('shape-files/', i, '.rds'))
  psnux <- psnu.vl2 %>% filter(OperatingUnit == i)
  shp_psnu <- merge(shpx, psnux, by.x = 'uid', by.y = 'PSNUuid')
  col_pal <- colorBin(palette = colfn, domain = shp_psnu@data$VL_Testing_Gap)
  sitex <- site.lab.xy2 %>% filter(OperatingUnit == i)
  
  #labels for labs
  labels <- sprintf(
    "<strong> %s <br/> Test Volume: %g",
    as.character(sitex$Facility), sitex$Test.Volume
  ) %>% lapply(htmltools::HTML)
  
  # final leaflet map
  mx <- leaflet() %>% 
    addTiles() %>% 
    addPolygons(data = shp_psnu, color='white', weight=1, opacity=1, 
                fillColor = ~col_pal(VL_Testing_Gap), fillOpacity = 1, label = ~PSNU) %>% 
    addCircleMarkers(data=sitex, lat = ~Latitude, lng = ~Longitude, radius = 8, label = labels, 
                     color = ~lab_col(cqi.status), fillOpacity = 1, stroke = FALSE) %>% 
    addLegend('bottomright', pal = col_pal, values =  shp_psnu@data$VL_Testing_Gap, title = 'Viral Load Testing Gap by PSNU', opacity = 1) %>% 
    addLegend('bottomleft', pal = lab_col, values = sitex$cqi.status, title = 'CQI Status of Viral Load Lab', opacity = 1)
  
  saveWidget(mx, paste0('map_', i, '.html'))
}

# Map function to do the same as above 
lab_map <- function(ou){
  shpx <-  read_rds(paste0('shape-files/', ou, '.rds'))
  psnux <- psnu.vl2 %>% filter(OperatingUnit == ou)
  shp_psnu <- merge(shpx, psnux, by.x = 'uid', by.y = 'PSNUuid')
  col_pal <- colorBin(palette = colfn, domain = shp_psnu@data$VL_Testing_Gap)
  sitex <- site.lab.xy2 %>% filter(OperatingUnit == ou)
  
  #labels for labs
  labels <- sprintf(
    "<strong> %s <br/> Test Volume: %g",
    as.character(sitex$Facility), sitex$Test.Volume
  ) %>% lapply(htmltools::HTML)
  
  # final leaflet map
  mx <- leaflet() %>% 
    addTiles() %>% 
    addPolygons(data = shp_psnu, color='white', weight=1, opacity=1, 
                fillColor = ~col_pal(VL_Testing_Gap), fillOpacity = 1, label = ~PSNU) %>% 
    addCircleMarkers(data=sitex, lat = ~Latitude, lng = ~Longitude, radius = 8, 
                     color = ~lab_col(cqi.status), fillOpacity = 1, stroke = FALSE, label = labels) %>% 
    addLegend('bottomright', pal = col_pal, values = shp_psnu@data$VL_Testing_Gap, title = 'Viral Load Testing Gap by PSNU', opacity = 1) %>% 
    addLegend('bottomleft', pal = lab_col, values = sitex$cqi.status, title = 'CQI Status of Viral Load Lab', opacity = 1)
  
  saveWidget(mx, paste0('map_', ou, '.html'))
}

# try function on one OU
lab_map("Cote d'Ivoire")

# run function on all OUs
lapply(countries, lab_map)


lab_map2 <- function(ou){
  shpx <-  read_rds(paste0('shape-files/', ou, '.rds'))
  psnux <- psnu.vl2 %>% filter(OperatingUnit == ou)
  shp_psnu <- merge(shpx, psnux, by.x = 'uid', by.y = 'PSNUuid')
  col_pal <- colorBin(palette = colfn, domain = shp_psnu@data$VL_Testing_Gap)
 
   # final leaflet map
  mx <- leaflet() %>% 
    addTiles() %>% 
    addPolygons(data = shp_psnu, color='white', weight=1, opacity=1, 
                fillColor = ~col_pal(VL_Testing_Gap), fillOpacity = 1, label = ~PSNU) %>% 
    addLegend('bottomright', pal = col_pal, values = shp_psnu@data$VL_Testing_Gap, title = 'Viral Load Testing Gap by PSNU', opacity = 1) 
  
  saveWidget(mx, paste0('map_', ou, '.html'))
}

lab_map2("Cameroon")
