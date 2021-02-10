***Last Updated: 02/06/21***

### [Return Home](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics) | [Previous Unit](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_1_Getting_Started/Unit2_Geography_Overview) | [Next Unit](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_1_Getting_Started/Unit4_Setting_Up)

# Unit 03: Types of Maps and Geographic Data

## **Vector Data**

[IMAGE]

Vector data provides a way to represent real world features within the GIS environment. A feature is anything that can be seen on the landscape. Imagine standing on the top of a hill. Looking down there are houses, roads, trees, rivers, etc. Each one of those would be a feature when represented in a GIS application.

Vector features have attributes, which consist of text or numerical information that describe the features (a table). A vector feature has its shape represented using geometry. The geometry is made up of one or more interconnected vertices.

In other words, **vector data are points, lines, and polygons and often saved as shapefiles**

--

## **Raster Data**

[IMAGE]

While vector features use geometry (points, lines, and polygons) to represent the real world, raster data takes a different approach. Rasters are made up of a matrix of pixels (also called cells), each containing a value that represents the conditions for the area covered by that cell. In this way, a raster dataset is similar to an image file.

Raster data is used in a GIS application when we want to display information that is continuous across an area and cannot easily be divided into vector features.

For example, when mapping grasslands, a user may want to depicit the many variations in color and density of cover. Instead of simplifying the features and creating a single polygon around each grassland area, a user can create a more detailed, grided dataset.

**Raster data are cell based files that are used to depict information such as population or percipitation. Instead of shapefiles, they'll be saved as a GeoTiff, PNG, or a similar file format.**

---

## **STATIC MAPS**

### **Choropleth Maps**

[IMAGE]

One of the most common maps used today, choropleths are a type of thematic map in which a set of pre-defined geographical areas or regions are colored, shaded or patterned in proportion to a statistical variable that represents an aggregate summary of a geographic characteristic within each area.

Within PEPFAR, these maps can be found in almost everything--from PLLs, COP, POARTs, Panorama, Operational Plans, and much more. Typically, choropleth maps are used to display one to three indicators.

**Strengths:**

* Display densities (ratios) of quantities using color.

**Weaknesses:**

* The maps are often generalized
* Not always uniform geographic areas

For examples of choropleth maps within and outside of PEPFAR, please open the [Map_Examples](LINK) folder.

--

### **Heat Maps**

[IMAGE]

Heat maps are used to aggregate the density of points to effectively visualize the intensity of the variable through a color scale. A heat map will show hot spots and other concentrations of points.

**Strengths:**

* Easy to understand relationships between data points and overall trends.

**Weaknesses:**

* Often used when geographic boundaries are not of importance.
* If the user is not careful, legibility can suffer.
* Color transitions may imply data or patterns that are not present.

For examples of heat maps within and outside of PEPFAR, please open the [Map_Examples](LINK) folder.

--

### **Proportional Symbol/Graduated Symbol Maps**

[IMAGE]

A common alternative to choropleth maps, these maps use points instead of colors to display attributes and/or statistics. Colors may also be used on top of the symbols, though users should avoid over-complicating the visualization. This type of map is used to visualize quantities rather than densities in choropleth map.

Outside of using site level datasets, information will usually be stored as polygons and later converted to centroids.

**Strengths:**

* It conveys where and how much (quantities).
* More effective showing raw quantities, rather than densities with choropleth maps.

**Weaknesses:**

* Less exact than distribution maps, depending on the size of the symbols.
* Can require preprocessing to derive centroids.
* Overlapping circles can be confusing. Users will have adjust symbol radius, transparency, or combine symboles as necessary. 

For examples of symbol based maps within and outside of PEPFAR, please open the [Map_Examples](LINK) folder.

--

### **Cartogram Maps**

[IMAGE]

Much less commonly used in PEPFAR, cartograms are a type of map in which the size of an area is rescaled to be proportional to the feature it represents. The rescaled size communicates the feature attributes selected, distorting area sizes.

While there are a few versions of cartograms, most GIS users creat contagious cartograms. This allows topology to be maintained, while still dramatically distorting the overall shape.

---

## **DYNAMIC MAPS**

Dynamic maps are similar to static maps. The major difference is that dynamic maps are hosted onto a digital plaftform allowing users to interact and manipulate it.

Within PEPFAR, the most accessible interactive maps can be found on Panorama, DATIM, and custom R Shiny/Python scripts. At an agency level, dynamic maps can also be produced within PowerBI and Tableau.

Due to data sensitivity concerns and hosting challenges, these maps are made on a case-by-case basis and not widely shared.

For examples of PEPFAR-specific web maps, please contact the GIS cluster.

---

Now that we have a background in geography and a better understanding of the types of maps that can be produced, please move on the next section for more information setting up your QGIS training environment.

### [Return Home](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics) | [Previous Unit](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_1_Getting_Started/Unit2_Geography_Overview) | [Next Unit](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_1_Getting_Started/Unit4_Setting_Up)