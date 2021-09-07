***Last Updated: 09/02/21***

### [Return Home](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics) | [Next Unit]()

<br><br />

# UNIT [02]: CREATING A SIMPLE FACILITY BASED MAP IN QGIS USING PEPFAR DATA

## **What is in this modeule?**

This training is for users who would like learn how to create a facility (point) based map in QGIS using PEPFAR programmatic data. While this module will only cover one basic example, there are many ways to display this type of data depending on user needs. 

<br><br />

## **Skills Needed to Execute this Module**

Before beginning this training, users should have the following skills:
* Basic knowledge of QGIS. For a quick introduction to the program, see the [QGIS 3.16 USER MANUAL](https://docs.qgis.org/3.16/en/docs/training_manual/index.html) or refer back to **UNIT 01**.
* Experience processing PEPFAR programmatic information into simplified Excel tables (csv).

<br><br />

---

<br><br />

## **STEP 1: GATHERING/IMPORTING DATA**

<br><br />

### Option A: GitHub Data
If you would like to use the provided data rather than your own, please download the following data from the **data** folder at the top of the page. This includes:

* **Country_Health_Facilities.csv**
* **Country_Programmatic_Data.csv**
* **Country_PSNU shapefile** (unzip files to working directory)

These datasets will be used throughout this training. 

<br><br />

### Option B: BYOD Data
If you would prefer to go through this module you will need 3 sets of data:

* **Programmatic Data** This data must:
    * Be in .csv format
    * Contain either PEPFAR uids or lat/long coordinates
* **PEPFAR Health Facility Locations** This data must:
    * Be in .csv format
    * Is not strictly needed if programmatic data already contains coordinate information
* **PEPFAR OU Polygon Shapefile**
    * Can be requested from your GIS Cluster representative

<br><br />

## **STEP 2: ADDING DATA TO QGIS**

<br><br />

### PART A: PSNU SHAPEFILE
Once the data is saved within your working directory, please open QGIS.

We will start by importing the PSNU shapefile. To do this, go to the top of the screen an click:

* **Layer**
* **Add Layer**
* **Add Vector Layer**

<!-IMAGE->

* **Vector Dataset(s)**: navigate to downloaded *.shp* file

<!-IMAGE->

Once loaded, QGIS will assign the data a random color: 

<!-IMAGE->

<br><br />

### PART B: PEPFAR FACILITY CSV TABLE
Once the PSNU shapefile is loaded, we now have to add the PEPFAR facility table. 

*This step can be skipped if your dataset already contains lat/longs and SNU/PNSU data.* 

To do this we follow a lot of the same steps as loading a shapefile:

<!-IMAGE->

* **Layer**
* **Add Layer**
* **Add Delimited Text Layer...**

<!-IMAGE->

Once in the menu, please find the *Country_Health_Facilities.csv* file using the three dot box to the right of: **File name**. While in this menu, it is important to get the **Point coordinates** within the **Geometry Definition** dropdown correct. As QGIS defaults to WGS84, most times you'll end up using your Longitude columnb as the **X field**. If you are unsure which field to put the lat/longs, simply add both before closing the window and remove the data layer that isn't displaying properly. 

<!-IMAGE->

As we were able to match the coordiantes to a spaital system, the table is now displayed as a point based shapefile within the table of contents. 

[Optional Step] If you would like to have this shapefile for future use, right click on *Country_Health_Facilities* in the table of contents and select **Export** -> **Save Features As...** -> **Format: ESRI Shapefile**

<br><br />

### PART C: PROGRAM DATA CSV TABLE
With both PSNU and point data now loaded into QGIS, we can add the non-geographic programmatic data. To do this, we can follow the same steps as **PART A**.

* **Layer**
* **Add Layer**
* **Add Vector Layer**

<!-IMAGE->

Notice the different icon next to the *Country_Programmatic_Data* table in the table of contents. This means the data we just loaded is a table with no spatial reference. It will not show up on the map until we add spatial data. 

<br><br />
<br><br />

## **STEP 3: JOINING FACILITY POINT SHAPEFILE TO PROGRAM DATA TABLE**

<br><br />

To add the programmatic data to the PEPFAR facility shapefile, we will be preforming a **join**. As we are joining the data table to our spatial data, start by going to the **Processing Toolbox** by clicking on this icon:

<!-IMAGE->

Using the search bar at the top, type in *"join"* and click on **Vector general** -> **Join attributes by field value**

<!-IMAGE->

**Join attributes by field value** menu, fill out the following fields:

<!-IMAGE->

* **Input layer** : *Country_Health_Facilities* 
    * --> shapefile 
* **Table field** : *uid*
    * --> column to be used to join with table
* **Input layer 2** : *Country_Programmatic_Data* 
    * --> table
* **Table field 2** : *fac_uid*
    * --> column to be used to join with shapefile
    
In this example we're using UIDs as the common field. Typically columns that are to be joined will have the same, if not similar name. It is important to understand your data to know which columns to use when joining. 

Once the tool has run, it will alert you to any rows that weren't matched. In this example, the program data table had 14 less facilities, matching the warning:

<!-IMAGE->

By default, this tool produces a temporary layer called *Joined layer*. To quickly find your temporary layers, look for the symbol below:

<!-IMAGE->

We can check our data by opening the attribute table. To do this, right click on *Joined layer* and find **Open Attribute Table**. This view opens up the data contained within a shapefile in tabluar form. Using this view, we can see the programmatic data has joined at the very far right of the table:

<!-IMAGE->

Filtering by facility, users can isolate the unmatched rows to check those as well. In the future, we will discuss how to remove those values if preferred.

<!-IMAGE->

Saving as temporary by default is helpful while making sure you have correctly joined your data. To make it a permanent shapefile, right click on *Country_Health_Facilities* in the table of contents and select **Export** -> **Save Features As...** -> **Format: ESRI Shapefile** . For this exercise, I will save out *Joined Layer* as ***Country_HF_Program*** , but it can be named anything.

<br><br />
<br><br />

## **STEP 4: BASIC SYMBOLOGY**

Now that our data is set, we can make it look a little nicer. There are many options for symbolizing data within QGIS but for this training, we will only be covering a few of the basic concepts. 

<!-IMAGE->

### STEP A: Change Colors

<br><br />

To start, we will be changing the colors to something more visually appealing, starting with the PSNU shapefile: 

* **Right-click** *Country_PNSU*
* **Properties**
* **Symbology**

<!-IMAGE->

Please take time to click around the various options and customize the PSNU symbology as you see fit. If you prefer the easiest option focus on:

* **Single symbol**
* **Simple fill**
* Adjust **Fill color** and **Stroke color** (border lines) as preferred.

<!-IMAGE->

Once finished, follow the same steps for *Country_HF_Program* : 

<!-IMAGE->
<!-IMAGE->

Alternatively, you may display the facility data by the programmatic data by selecting **Graduated** instead of **Single** at the top menu dropdown and choose *TXC20Q4* as **Column** :

<!-IMAGE->
<!-IMAGE->


### STEP B: Adding Labels

<br><br />

To help with geographic context, we will be adding labels to the PSNU polygon shapefile. Start by going back into layer **Properties** again, but instead of **Symbology**, click on **Labels**. Once in the menu, select **Single labels** from the dropdown:

<!-IMAGE->
<!-IMAGE->

Once in the **Single labels** menu, change **Label with** to *orgunit_na*. If you simply want labels, these are all the step needed. Please click around this menu if you would like to customize the labels further. 

<!-IMAGE->

If you are fine with the map as it looks now, navigate to the top right of QGIS, click **Project** -> click **Import/Export** -> **Export map to image**

<br><br />
<br><br />

## **STEP 5: PRINT COMPOSER**

<br><br />

### STEP A: Setting Up

<br><br />

To further customize the layout of the map, we will create a new print layout.

* **Project** -> **New Print Layout** -> Name it accordingly [I used *"Map1"*]

<!-IMAGE->

Once faced with a blank map, click on the **Add a new map to the layout** icon

<!-IMAGE->

and create a box of where on the page you'd like the map

<!-IMAGE->

<br><br />

### STEP B: Adding A Title

<br><br />

To add a title:

* **Add item** -> **Add label**

To add at legend:

* **Add item** -> **Add Legend**

TO add a scale bar:

* **Add item** -> **Add Scale Bar**

<!-IMAGE->

Once finished editing your map, you can export the map by going to **Layout** -> **Export as Image..**




<br><br />
<br><br />



### [Return Home](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics) | [Next Unit]()
