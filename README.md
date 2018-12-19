

# bjzresc
An R package with functions frequently used in Jianzhao's research
# Installation
To get the current development version from github:
``` R
# install.packages("devtools")
devtools::install_github("jianzhaobi/bjzresc")
```

## GDAL Library
Some functions (*e.g.,* `readMCD19A2`) need the R package `rgdal` which requires the GDAL library. This library can be installed in your linux directory without root permission.

GDAL doesn't include HDF4 ([download here](https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.10/src/hdf-4.2.10.tar.gz)) and HDF5 ([download here](https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.12/src/hdf5-1.8.12.tar.gz)) support by default. If your system doesn't have HDF4 and HDF5 libraries, please download and install them first (http://hdfeos.org/software/gdal.php).

To install these libraries, gcc/g++ ([download here](http://www.netgull.com/gcc/releases/gcc-5.2.0/)) is needed. So, this should be installed first.

### Install `GCC` (version 5.2.0)
``` bash
tar xzf gcc-5.2.0.tar.gz
cd gcc-5.2.0
./contrib/download_prerequisites
cd ..
mkdir objdir
cd objdir
$PWD/../gcc-5.2.0/configure --prefix=$HOME/gcc-5.2.0 --enable-languages=c,c++,fortran,go
make
make install
```
Now gcc and g++ will be installed on your system. If you would like to use the installed version of gcc (in this case`gcc-5.2.0` overthe preinstalled gcc, you can simply add
``` bash
export PATH=~/gcc-5.2.0/bin:$PATH
export LD_LIBRARY_PATH=~/gcc-5.2.0/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=~/gcc-5.2.0/lib64:$LD_LIBRARY_PATH
```
to your `~/.bashrc`.

### Install `HDF4`
``` bash
# HDF4
cd hdf-version.num # Extracted from `hdf.tar.gz`
./configure --prefix=/path --disable-netcdf
make
make install
```
### Intall `GDAL`
``` bash
cd gdal-version.num # Extracted from `gdal.tar.gz`
# Install GDAL with HDF4 support
CFLAGS="-fPIC" ./configure --prefix=/path --with-hdf4=/path --with-hdf5=no
make
make install
```
Add  
``` bash
export PATH=/path/bin:$PATH
export LD_LIBRARY_PATH=/path/lib:$LD_LIBRARY_PATH
export GDAL_DATA=/path/share/gdal
``` 
to your `~/.bashrc`.

In order to run GDAL after installing it is necessary for the shared library to be findable. This can often be accomplished by setting `LD_LIBRARY_PATH` to include `/usr/local/lib`.

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
## Purple Air
### getPurpleairLst
``` R
getPurpleairLst(output.path)
```
* ***Description***
	* Get a list of the latest PurpleAir sensors from PurpleAir JSON (https://www.purpleair.com/json) and save as a CSV file.
* ***Parameters***
	* `output.path`: the path of the output CSV file
* ***Examples***
``` R
getPurpleairLst('/path')
``` 
### purpleairDownload
``` R
purpleairDownload <- function(site.csv, start.date, end.date, output.path, average, time.zone = 'GMT', indoor = F)
```
* ***Description***
	* Download Purple Air PM2.5 data and save as csv files (each PurpleAir site per file). The indoor sites are not included by default.
* ***Parameters***
	* `site.csv`: a absolute path to the site CSV file (obtain by get_sensorlist_json).
	* `start.date`: the beginning date with the format `YYYY-MM-DD`.
	* `end.date`: the end date with the format `YYYY-MM-DD`.
	* `output.path`: the path to output CSV files.
	* `average`: get average of this many minutes, valid values: 10, 15, 20, 30, 60, 240, 720, 1440, "daily"
	* `time.zone`: time zone specification to be used for the conversion, but "" is the current time zone, and "GMT" is UTC (Universal Time, Coordinated). Invalid values are most commonly treated as UTC, on some platforms with a warning.
	* `indoor`: whether includes indoor sites (`FALSE` by default).
* ***Examples***
``` R
purpleairDownload(site.csv = '/path/sensorlist.csv',
	start.date = '2017-01-01',
	end.date = '2017-12-31',
	output.path = '/output_path',
	average = 60,
	time.zone = 'America/Los_Angeles')
``` 

# Miscellaneous
## Notes
* Learn how to turn your code into packages that others can easily download and use: [R packages](http://r-pkgs.had.co.nz/)
* The R Package Development Cheatsheet can be found [here](https://www.rstudio.com/wp-content/uploads/2015/03/devtools-cheatsheet.pdf).
* The documentation of the R codes are generated by the package `roxygen2` (https://github.com/klutometis/roxygen).
* The README documentation of this github project is edited by [StackEdit](https://stackedit.io/). 

## Tricks of Building R Packages

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
eyJoaXN0b3J5IjpbMjEyNzM4MTMwNCwtNjM2OTUxMjM5LDEwNT
M0NTEyNzksLTE2Mzk4NDkwNDUsLTcwNzAyMDk1NywtMTQ3NDAw
NTA0MSwtNTI1MzcxODE5LDQ0MDU0NDMyNSwxNjEwNTkyOTMwLC
0xODgxNzA5OTY4LC01OTQ0ODcxMCwtMTgwNTk3NzA1OSwtMTEx
OTY5MTYxMSwtMTA1NDQzNDkzMiwtMTgyOTExOTUxMiwxMjkyOD
M5MTAyLDQ0NDI1MTgzMywzMjgxMTQ4MTQsMTE2MTM2MTA3LDEw
OTk4OTc2ODhdfQ==
-->