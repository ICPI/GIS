
# Script to create GIS analysis for South Sudan
# Requesting for the following combination of maps:
# 1. Plotting or color coding County by the IM (implementing NGO partners)
# 2. Plotting or color coding State by IM
# 3. Mapping the locations of all the Facilities (Facility column) on the map on both #1 and 2 above.
#     a. One map with Agency wise facility distinction i.e. the CDC, USAID and DOD facilities to be shown differently e.g. a solid triangle vs. square vs. circle
#     b. One map with IM wise facility distinction i.e. JHPIEGO, ICAP, IHI, CMMB and RTI facilities to be shown differently
# 4. Plotting or color coding County by Field Officers with 3b also plotted
# 5. Plotting or color coding State by Field Officers with 3b also plotted
# 6. Mapping the locations of all the Field Officers on the map on both #1 and 2 above with each Field officer highlighted with a different shape/color


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ============= Functions used in code ~~~~~~~===============
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Creating basic functions to show top few rows of data
View50 <- function(x){View(x[1:50,])}
View100 <- function(x){View(x[1:100,])}

# Creating the 'not in' function
`%ni%` <- Negate(`%in%`) 

# Load function to install list of packages
ldpkg <- dget("R_scripts/ldpkg.R")


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ============= Load (install, if required!) packages ~~~~~~~===============
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#  Load packages, and install them if they are not already installed, before loading
ldpkg( c("leaflet" , 
         "rgdal" , 
         "rgeos", 
         "sp", 
         "RColorBrewer", 
         "tidyverse", 
         "readxl") )


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ============= GIS Data Acquisition ~~~~~~~===============
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Pulling the shape files
ss_states <- readOGR(dsn='SSudan_req/SouthSudanStatesLsib2016May', 
                        layer = 'SouthSudanStatesLsib2016May')

ss_county <- readOGR(dsn='SSudan_req/SouthSudan_PROD_5_County_CountyLsib_2017_May', 
                     layer = 'SouthSudan_PROD_5_County_CountyLsib_2017_May')

# Pulling the coordinate data
ss_sites <- readOGR(dsn='SSudan_req/ssudan_sites', 
                     layer = 'ssudan_sites')


# check CRS projection 
proj4string(ss_states)
proj4string(ss_county)
proj4string(ss_sites)

# change CRS to 
ss_state <- spTransform(ss_states,"+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")  



leaflet(ss_state) %>%   
  addPolygons(fillColor="grey",
              color='white', weight=2, opacity=.7, fillOpacity = 0.8) %>% 
  addPolygons(data = ss_county, fillColor="none",
              color='orange', weight=.5, opacity=.7, fillOpacity = 0.7) %>%  
  addCircles(data=ss_sites, lng=~longitude, lat=~latitude, radius=4, opacity=1, fillOpacity=2,
                   color="#335b8e", stroke=T, fill=T, fillColor = "blue") %>% 
  addScaleBar()


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ============= Pulling data from provided Excel file ~~~~~~~====
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
xlpath <- "SSudan_req/RawData/Field Officers PEPFAR Sites Allocations_02202019.xlsx"
df <- read_excel(xlpath, range = "Field Officers!A1:I40")

# Recoding variables in data to match shape files
df1 <- df %>% 
  rename(s_no           = "S No",                     
         level5name     = "PSNU / County",            
         field_Officers = "HIV Field Officers",    
         focal_person   = "PEPFAR focal Point person") %>% 
  mutate(level4name = paste(`Former State`, " ", "State", sep="") )

         
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ============= Map 1, with county-level data by IM ~~~~~~~====
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~         
m1 <- df1 %>% 
  select(level5name, IM) %>% 
  unique() %>% 
  filter(!is.na(level5name)) %>% 
  filter(level5name %ni% c("_Military South Sudan")) %>%
  group_by(level5name) %>% 
  mutate(imcol = row_number()) %>% 
  ungroup() %>% 
  mutate(imcol = paste("IM", imcol, sep="_")) %>% 
  spread(imcol, IM) %>% 
  # Creating the concatenated IM variable
  mutate(IMs = if_else(is.na(IM_2), IM_1, paste(IM_1, IM_2, sep=" | "))) %>% 
  select(level5name, IMs)


# Checking matching counties
sh_county <- unique(ss_county$level5name)
df_county <- unique(m1$level5name)
  
# County names in df but not in shape file
setdiff(df_county, sh_county)

map1 <- merge(ss_county, m1, by="level5name", duplicateGeoms = TRUE)

map1x <- map1[!is.na(map1$IMs),]

# Reordering the IM factors to show overlapping ones together
map1x$im <- factor(map1x$IMs, levels = c("ICAP",
                                          "ICAP | JHPIEGO",
                                          "ICAP | IHI",
                                          "JHPIEGO",
                                          "IHI",
                                          "CMMB"))
                                          



#  pallate based on IM name
pal_im <- colorFactor(palette = c('#ceb966',   # vegas gold: ICAP
                                  '#9cb084',   # Olivine: ICAP|JHIPIEGO
                                  '#fddbc7',   # unbleached silk: ICAP|IHI
                                  '#6bb1c9',   # dark sky blue: JHIPIEGO
                                  '#ef8a62',   # salmon: IHI
                                  '#a379bb'   # rich lilac: CMMB
                                  ), 
                   domain = map1x$im)

leaflet(map1x) %>%   
  addPolygons(data=ss_state, fillColor="none",
              color='darkgrey', weight=4, opacity=.9, fillOpacity = 0.1) %>% 
  addPolygons(data = map1, fillColor="grey",
              color='white', weight=.5, opacity=.5, fillOpacity = 0.3) %>% 
  addPolygons(data = map1x, fillColor=~pal_im(im),
              color='white', weight=.5, opacity=.5, fillOpacity = 0.6,
              label=~level5name, 
              labelOptions = labelOptions(noHide = T, direction = 'center', 
                                          style = list("color" = "black"))) %>% 
  addLegend(pal = pal_im, values = ~im,
            opacity = 0.9, title = 'IMs', position = "bottomright") %>% 
  addScaleBar()
  

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ============= Map 2, with State-level data by IM ~~~~~~~====
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~         
m2 <- df1 %>% 
  select(level4name, IM) %>% 
  unique() %>% 
  filter(!is.na(level4name)) %>% 
  filter(level4name %ni% c("_Military South Sudan"))

# Checking matching counties
sh_state <- unique(ss_state$level4name)
df_state <- unique(m2$level4name)

# County names in df but not in shape file
setdiff(df_state, sh_state)

map1 <- merge(ss_county, m1, by="level5name", duplicateGeoms = TRUE)

merge(spatial_data, data_frame, by = 'match_column', duplicateGeoms = TRUE)
map1 <- merge(ss_county, m1, by.x = "level5name", by.y = "level5name")

map1x <- map1[!is.na(map1$IM),]


#  pallate based on IM name
pal_im <- colorFactor(palette = c('#335b8e', 
                                  '#6ca18f', 
                                  '#b5b867',
                                  '#cc5234'), 
                      domain = map1x$IM)

leaflet(map1x) %>%   
  addPolygons(data=ss_state, fillColor="none",
              color='white', weight=2, opacity=.7, fillOpacity = 0.1) %>% 
  addPolygons(data = map1, fillColor="grey",
              color='white', weight=.5, opacity=.7, fillOpacity = 0.3) %>% 
  addPolygons(data = map1x, fillColor=~pal_im(IM),
              color='white', weight=.5, opacity=.7, fillOpacity = 0.7,
              label=~level5name, 
              labelOptions = labelOptions(noHide = T, direction = 'center', 
                                          style = list("color" = "black"))) %>% 
  addLegend(pal = pal_im, values = ~IM,
            opacity = 0.9, title = 'IMs', position = "bottomright") %>% 
  addScaleBar()


         
         
         
         
         
         
         
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ============= Getting MER data ~~~~~~~===============
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Getting the MSD dataset file names
glist <- list.files("SSudan_req/RawData/"
                    , pattern="MER")

gfile_loc <- paste("SSudan_req/RawData/", glist[1], sep="") 

# Rough data pull to get variable names and assign datatype
foo <- read_tsv(file=gfile_loc, 
                col_names = TRUE, n_max = 0)   

foonames <- tolower(names(foo))

# Creating the vector of column types
colvecx <- as.vector(ifelse(grepl("fy", foonames), "d", "c"))
# colvecx <- as.vector(ifelse(foonames %in% c("FILL IN STUFF HERE"  ), "d", "c"))

# Collapsing the vector into a single string variable
colvec <- paste(colvecx, collapse = '')

# Pulling in the data with correct datatype for variables  
datim <- read_tsv(file=gfile_loc, 
                  col_names = TRUE,
                  col_types = colvec)      # ending if-else for Genie check

names(datim) <- tolower(names(datim))  


df <- datim %>% 
  select(snu1, psnuuid, psnu, orgunituid, sitename, sitetype,
         fundingagency, primepartner, mechanismid, implementingmechanismname) %>% 
  unique() 





