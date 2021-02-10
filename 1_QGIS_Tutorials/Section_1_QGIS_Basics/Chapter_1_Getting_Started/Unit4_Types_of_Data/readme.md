***Last Updated: 02/06/21***

### [Return Home](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics) | [Previous Unit](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_1_Getting_Started/Unit3_Types_of_Maps) | [Next Chapter](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_2_Using_QGIS)

# Unit 04: Types of Geographic Data

## **Vector Data**

[IMAGE]

Vector data provides a way to represent real world features within the GIS environment. A feature is anything that can be seen on the landscape. Imagine standing on the top of a hill. Looking down there are houses, roads, trees, rivers, etc. Each one of those would be a feature when represented in a GIS application.

Vector features have attributes, which consist of text or numerical information that describe the features (a table). A vector feature has its shape represented using geometry. The geometry is made up of one or more interconnected vertices.

In other words, **vector data are points, lines, and polygons and often saved as shapefiles**

**Examples of Vector Data:**

* Shapefiles [.shp - .shx - .dbf - .prj]
* KML/KMZ Files
* SVG
* XML
* JSON/TopoJSON/GeoJSON
* GML
* OSX

**Strengths:**

* Data can be represented at its original resolution and form without generalization.
* Since most data, e.g. hard copy maps, is in vector form no data conversion is required.
* Accurate geographic location of data is maintained.
* Allows for efficient encoding of topology, and as a result more efficient operations that require topological information, e.g. proximity, network analysis.

**Weaknesses:**

* The location of each vertex must be stored explicitly. This can sometimes lead to large file sizes for very detailed datasets.
* For effective analysis, vector data must sometimes be converted into a topological structure. This is often processing intensive and usually requires extensive data cleaning. Any future updating or editing of the vector data may require re-building the topology.
* Algorithms for manipulative and analysis functions are complex and may be processing intensive. Often, this inherently limits the functionality for large data sets, e.g. a large number of features.
* Continuous data, such as elevation data, is not effectively represented in vector form. Usually substantial data generalization or interpolation is required for these data layers.
* Spatial analysis and filtering within polygons is impossible

--

## **Raster Data**

[IMAGE]

While vector features use geometry (points, lines, and polygons) to represent the real world, raster data takes a different approach. Rasters are made up of a matrix of pixels (also called cells), each containing a value that represents the conditions for the area covered by that cell. In this way, a raster dataset is similar to an image file.

Raster data is used in a GIS application when we want to display information that is continuous across an area and cannot easily be divided into vector features.

For example, when mapping grasslands, a user may want to depicit the many variations in color and density of cover. Instead of simplifying the features and creating a single polygon around each grassland area, a user can create a more detailed, grided dataset.

[NOTE ABOUT RESOLUTION]

**Raster data are cell based files that are used to depict information such as population or percipitation. Instead of shapefiles, they'll be saved as a GeoTiff, PNG, or a similar file format.**

**Examples of Vector Data:**

* GeoTiff/Tiff
* PNG/JPG/GIF
* ASCII
* Various Types of Satellite Imagery File Formats

**Strengths:**

* The geographic location of each cell is implied by its cell position in the grided matrix (bottom left corner of the cell).
* Due to the nature of the data storage technique data analysis is usually easy to program and quick to perform.
* The inherent nature of one attribute raster maps is ideally suited for mathematical modeling and quantitative analysis.
* Discrete data, is accommodated equally well as continuous data and facilitates the integrating of the two data types.

**Weaknesses:**

* No geographic coordinates are stored.
* The cell size determines the resolution at which the data is represented.;
* It is difficult to represent linear features depending on the cell resolution. This makes network linkages difficult to establish.
* Processing of attribute data may be cumbersome if large amounts of data exists. Raster maps inherently reflect only one attribute or theme for an area.
* Since most input data is in vector form, data must often undergo vector-to-raster conversion. Besides increased processing requirements this may introduce data integrity concerns due to generalization and choice of inappropriate cell size.
* Most output maps from grid-cell systems do not conform to high-quality cartographic needs.

---

Now that we have a background in geography and a better understanding of the types of maps that can be produced, please move on the next chapter for more information on how to install QGIS and how to set up a training environment.

### [Return Home](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics) | [Previous Unit](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_1_Getting_Started/Unit3_Types_of_Maps) | [Next Chapter](https://github.com/ICPI/GIS/tree/master/1_QGIS_Tutorials/Section_1_QGIS_Basics/Chapter_2_Using_QGIS)