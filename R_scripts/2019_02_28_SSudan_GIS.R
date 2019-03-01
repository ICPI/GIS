
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
ldpkg( c("leaflet" , "rgdal" , "rgeos", "sp", "RColorBrewer", "tidyverse") )


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
              color='#FF6633', weight=.5, opacity=.5, fillOpacity = 0.7) %>%  
  addCircles(data=ss_sites, lng=~longitude, lat=~latitude, radius=4, opacity=1, fillOpacity=2,
                   color="#335b8e", stroke=T, fill=T, fillColor = "blue") %>% 
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




