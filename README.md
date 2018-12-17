

# bjzresc
An R package with functions frequently used in Jianzhao's research
# Installation
To get the current development version from github:
``` R
# install.packages("devtools")
devtools::install_github("jianzhaobi/bjzresc")
```
# Main Functions
## Tools
### cutByShp
``` R
cutByShp(myshp, dat, lat.name, long.name)
```
* ***Description***
	* Clip a data frame by a shapefile
* ***Parameters***
	* `myshp`: the shapefile (*class SpatialPolygonsDataFrame*) that must be based on WGS84 coordinate system
	* `dat`: the data frame to be cut that must include WGS84 lat/long coordinates
	* `lat.name`: the name of the column about latitude in `dat`
	* `long.name`: the name of the column about longitude in `dat`
* ***Return***
	* a subset of the data frame clipped by the shapefile
* ***Examples***
```R
cutByShp(myshp = shp, dat = df, lat.name = 'Lat', long.name = 'Lon')
```
## MCD19A2 (MAIAC AOD)
### readMCD19A2
``` R
readMCD19A2(file.name, latlong.range = NULL, border.shp = NULL)
```
* ***Description***
	* Read MCD19A2 HDF-4 files
* ***Parameters***
	* `file.name`: the name of input HDF file with an *absolute* path
	* `latlong.range`: the lat/long range with the structure `c(lon.min, lon.max, lat.min, lat.max)`, cannot be used with `border.shp`
	* `border.shp`: a shapefile (*class SpatialPolygonsDataFrame*), cannot be used with `latlong.range`
* ***Return***
	* A list with time stamps and MAIAC AOD data in multiple bands
* ***Examples***
``` R
# Using lat/long coordinates to clip the data
readMCD19A2(file.name = '/path/file.HDF', latlong.range = c(132, 133, 56, 57))
# Using a polygon to clip the data
readMCD19A2(file.name = '/path/file.HDF', border.shp = myshp)
```

# Miscellaneous
## Notes
* Learn how to turn your code into packages that others can easily download and use: [R packages](http://r-pkgs.had.co.nz/)
* The R Package Development Cheatsheet can be found [here](https://www.rstudio.com/wp-content/uploads/2015/03/devtools-cheatsheet.pdf).
* The documentation of the R codes are generated by the package `roxygen2` (https://github.com/klutometis/roxygen).
* The README documentation of this github project is edited by [StackEdit](https://stackedit.io/). 

## Some Tricks of Building R Packages

### Add required dependencies
he easiest way to add `Imports` and `Suggests` to your package is to use `devtools::use_package()`. This automatically puts them in the right place in your `DESCRIPTION`, and reminds you how to use them.
``` R
devtools::use_package("dplyr") # Defaults to imports
#> Adding dplyr to Imports
#> Refer to functions with dplyr::fun()
devtools::use_package("dplyr", "Suggests")
#> Adding dplyr to Suggests
#> Use requireNamespace("dplyr", quietly = TRUE) to test if package is 
#>  installed, then use dplyr::fun() to refer to functions.
```
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTYxNTc3MzcxMCwtMTgwNTk3NzA1OSwtMT
ExOTY5MTYxMSwtMTA1NDQzNDkzMiwtMTgyOTExOTUxMiwxMjky
ODM5MTAyLDQ0NDI1MTgzMywzMjgxMTQ4MTQsMTE2MTM2MTA3LD
EwOTk4OTc2ODhdfQ==
-->