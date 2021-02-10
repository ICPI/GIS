***Last Updated: 02/06/21***

### [Return Home](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics) | [Previous Unit](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_1_Getting_Started/Unit2_Geography_Overview) | [Next Unit](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_1_Getting_Started/Unit4_Types_of_Data)

# Unit 03: Types of Maps

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

[IMAGE]

Dynamic maps are similar to static maps. The major difference is that dynamic maps are hosted onto a digital plaftform allowing users to interact and manipulate it.

Within PEPFAR, the most accessible interactive maps can be found on Panorama, DATIM, and custom R Shiny/Python scripts. At an agency level, dynamic maps can also be produced within PowerBI and Tableau.

Due to data sensitivity concerns and hosting challenges, these maps are made on a case-by-case basis and not widely shared.

For examples of PEPFAR-specific web maps, please contact the GIS cluster.

**Strengths:**

* Enhanced user control.
* Ablility to handle many different types of data and map themes.

**Weaknesses:**

* Can become overcrowded.
* User interfaces can be confusing to some users.
* Set-up time can be time consuming.
* Hosting a dynamic map may be difficult.

---

Please click on *Next Unit* to continue onto learning about the types of data used withing a GIS.

### [Return Home](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics) | [Previous Unit](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_1_Getting_Started/Unit2_Geography_Overview) | [Next Unit](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_1_Getting_Started/Unit4_Types_of_Data)