

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

## Lag-Day Creators
### singleDayLag
``` R
singleDayLag(data, lag)
```
* ***Description***
	* Single-Day Lag Creator
* ***Parameters***
	* `data`: a vector for which the single-day lag is created
	* `lag`: a non-negative integer indicating the lag day
* ***Return***
	* A `crossbasis` matrix showing the single-day lag
* ***Examples***
``` R
# Lag 1
singleDayLag(data = df$pm25, lag = 1)
```

### unconDistLag
``` R
unconDistLag(data, lag1, lag2)
```
* ***Description***
	* Unconstrained Distributed Lag Creator
* ***Parameters***
	* `data`: a vector for which the distributed lag is created
	* `lag1`: a non-negative integer indicating the starting lag day (lag2 > lag1)
	* `lag2`: a non-negative integer indicating the ending lag day (lag2 > lag1)
* ***Return***
	*  A `crossbasis` matrix showing the distributed lag
* ***Examples***
``` R
# Lag 0-3
unconDistLag(data = df$pm25, lag1 = 0, lag2 = 3)
```

### movAvgLag
``` R
movAvgLag(data, lag1, lag2)
```
* ***Description***
	* Moving Average Creator
* ***Parameters***
	* `data`: a vector for which the moving average is created
	* `lag1`: a non-negative integer indicating the starting lag day (lag2 > lag1)
	* `lag2`: a non-negative integer indicating the ending lag day (lag2 > lag1)
* ***Return***
	*  A `crossbasis` matrix showing the moving average
* ***Examples***
``` R
# MA 0-3
movAvgLag(data = df$pm25, lag1 = 0, lag2 = 3)
```

### Examples

Here is some examples showing how to use the lag-day creators. The R package `dlnm` (https://cran.r-project.org/web/packages/dlnm/index.html) is required. 

The sample data, `data`, have 100 rows and 5 columns. Each row is a single day's data, and each column is a parameter:

* `OUTCOME`: Daily counts of the health outcome
* `PM25`: Daily PM2.5 levels
* `TEMPMAX`: Daily max air temperature
* `SEASON`: Season indicators
* `TIME`: Time trend

#### Singe-Day Lag
This block shows the specification of the lag 3 of PM2.5 and max air temperature.
```R
# --- Specification --- #
# Pollution
pol <- singleDayLag(data = data$PM25, lag = 3)
# Temperature control
tmax <- singleDayLag(data = data$TEMPMAX, lag = 3)
```

#### Unconstrained Distributed Lag
This block shows the specification of the lag 0-3 of PM2.5 and max air temperature.
```R
# --- Specification --- #
# Pollution
pol <- unconDistLag(data = data$PM25, lag1 = 0, lag2 = 3)
# Temperature control
tmax <- movAvgLag(data = data$TEMPMAX, lag1 = 0, lag2 = 3)
```

#### Moving Average
This block shows the specification of the MA 0-3 of PM2.5 and max air temperature.
```R
# --- Specification --- #
# Pollution
pol <- movAvgLag(data = data$PM25, lag1 = 0, lag2 = 3)
# Temperature control
tmax <- movAvgLag(data = data$TEMPMAX, lag1 = 0, lag2 = 3)
```

#### Modeling and Prediction
Here `OUTCOME` is the outcome variable, `pol` is the target pollution lag days, `tmax + I(tmax^2) + I(tmax^3)` is the square and cubic terms of max temperature, `ns(TIME, df = 3)` is  time splines with degrees of freedom of 3, and `SEASON` is the season indicator. 

For `glm`, `quasipoisson` is the Quasi-Poisson model to account for overdispersion. For `crosspred`, `at` is each unit increase of the pollutant, and `ci.level` is the confidence interval.

Note: for the time splines, the R package `splines` is required.
```R
library(splines)

# --- Formula --- #
fm <- OUTCOME ~ pol + tmax + I(tmax^2) + I(tmax^3) + ns(TIME, df = 3) + SEASON

# --- Modeling --- #
mdl <- glm(formula = fm, family = quasipoisson(), data = data)
pred <- crosspred(basis = pol, model = mdl, at = 10, ci.level = 0.95)

# --- Rate Ratios --- #
RR <-  pred$allRRfit
RR.Low <- pred$allRRlow
RR.High <- pred$allRRhigh
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
## PurpleAir Low-Cost PM Data
### getPurpleairLst
``` R
getPurpleairLst(output.path = NULL)
```
* ***Description***
	* Get a list of the latest PurpleAir sensors from PurpleAir JSON (https://www.purpleair.com/json) and save as a CSV file.
* ***Parameters***
	* `output.path`: the path of the output CSV file. By default, this variable equals `NULL` and the list is saved as a data frame.
* ***Return***
	* The latest PurpleAir sensor list as the data frame format
* ***Examples***
``` R
# Save as a CSV file 
getPurpleairLst('/absolute/path/to/the/csv/file')
# Save as a data frame variable
sensor.lst <- getPurpleairLst()
``` 
### purpleairDownload
``` R
purpleairDownload <- function(site.csv, start.date, end.date, output.path, average, time.zone = 'GMT', indoor = T)
```
* ***Description***
	* Download Purple Air PM2.5 data and save as csv files (each PurpleAir site per file). The indoor sites are not included by default.
* ***Parameters***
	* `site.csv`: a data frame of a site list or a absolute path to the site CSV file (from `getPurpleairLst`).
	* `start.date`: the beginning date in the format `YYYY-MM-DD`.
	* `end.date`: the end date in the format `YYYY-MM-DD`.
	* `output.path`: the path to output CSV files.
	* `average`: get average of this many minutes, valid values: 10, 15, 20, 30, 60, 240, 720, 1440, "daily". "daily" is not recommended as the daily values can only be calculated at the UTC time.
	* `time.zone`: time zone specification to be used for the conversion, but "" is the current time zone, and "GMT" is UTC (Universal Time, Coordinated). Invalid values are most commonly treated as UTC, on some platforms with a warning. For more time zones, see https://www.mathworks.com/help/thingspeak/time-zones-reference.html.
	* `indoor`: whether includes indoor sites (`TRUE` by default).
	* `n.thread`: number of parallel threads used to download the data (1 by default).
* ***Examples***
``` R
purpleairDownload(site.csv = '/absolute/path/to/the/sensorlist.csv',
	start.date = '2017-01-01',
	end.date = '2017-12-31',
	output.path = '/output_path',
	average = 60,
	time.zone = 'America/Los_Angeles')
``` 

## GDAL Library
Some functions (*e.g.,* `readMCD19A2`) need the R package `rgdal` which requires the GDAL library. This library can be installed in your linux directory without root permission. Make sure there is enough (**~10G**) space on your device. 

GDAL doesn't include HDF4 ([download](https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.10/src/hdf-4.2.10.tar.gz)) and HDF5 ([download](https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.12/src/hdf5-1.8.12.tar.gz)) support by default. If your system doesn't have HDF4 and HDF5 libraries, please download and install them first (http://hdfeos.org/software/gdal.php).

To install these libraries, gcc/g++ ([gcc-5.2.0](http://www.netgull.com/gcc/releases/gcc-5.2.0/)) is needed. So, this should be installed first.

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

### Install `ZLIB`, `JPEG`, and `PROJ`
* ZLIB binaries can be downloaded from [here](https://zlib.net/). 
* JPEG binaries can be downloaded from [here](https://www.ijg.org/). 
* PROJ binaries can be downloaded from [here](https://proj4.org/download.html). Make sure to download both `proj.tar.gz` and `proj-datumgrid.zip` 
``` bash
# Install ZLIB
cd zlib # Extracted from `zlib.tar.gz`
./configure --prefix=/path_to_ZLIB_install_directory
make test
# if tests are OK, then
make install

# Install JPEG
cd jpeg # Extracted from `jpeg.tar.gz`
./configure --prefix=/path_to_JPEG_install_directory
make
make install

# Install PROJ
cd proj # Extracted from `proj.tar.gz`
./configure --prefix=/path_to_PROJ_install_directory
unzip proj-datumgrid.zip -d proj/data/ # add the datum grids
make
make install
```
### Install `HDF4`
Make sure that the `ZLIB` and `JPEG` libraries are installed on your system.
``` bash
# HDF4
cd hdf # Extracted from `hdf.tar.gz`
./configure --with-zlib=/path_to_ZLIB_install_directory
                   --with-jpeg=/path_to_JPEG_install_directory
                   --prefix=/path_to_HDF4_install_directory
                   --enable-shared --disable-fortran # This line is important for GDAL. 
# See https://lists.osgeo.org/pipermail/gdal-dev/2016-April/044125.html for detail.
# To build the library:
gmake >& gmake.out
# To build and run the tests:
gmake check >& check.out
# To install the HDF4 library and tools:
gmake install
# To install C and Fortran examples:
gmake install-examples
# To test the installation:
gmake installcheck
```
### Intall `GDAL`
GDAL binaries can be downloaded from [here](https://trac.osgeo.org/gdal/wiki/DownloadSource).
``` bash
cd gdal # Extracted from `gdal.tar.gz`
# Install GDAL with HDF4 support
./configure --prefix=/path_to_GDAL_install_directory --with-hdf4=/path_to_HDF4_install_directory
make
make install
```
Add  
``` bash
export PATH=/path_to_GDAL_install_directory/bin:$PATH
export LD_LIBRARY_PATH=/path_to_GDAL_install_directory/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/path_to_GDAL_install_directory/lib64:$LD_LIBRARY_PATH
export GDAL_DATA=/path_to_GDAL_install_directory/share/gdal
``` 
to your `~/.bashrc`.

In order to run GDAL after installing it is necessary for the shared library to be findable. This can often be accomplished by setting `LD_LIBRARY_PATH` to include `/usr/local/lib`.

### Install R Package `rgdal`
```R
install.packages("rgdal", configure.args = c("--with-proj-include=/path/to/proj/include", "--with-proj-lib=/path/to/proj/lib"))
```

# Miscellaneous
## Notes
* Learn how to turn your code into packages that others can easily download and use: [R packages](http://r-pkgs.had.co.nz/)
* The R Package Development Cheatsheet can be found [here](https://www.rstudio.com/wp-content/uploads/2015/03/devtools-cheatsheet.pdf).
* The documentation of the R codes are generated by the package `roxygen2` (https://github.com/klutometis/roxygen).
* The README documentation of this github project is edited by [StackEdit](https://stackedit.io/). 

## Tricks of Building R Packages

### Add required dependencies
The easiest way to add `Imports` and `Suggests` to your package is to use `devtools::use_package()`. This automatically puts them in the right place in your `DESCRIPTION`, and reminds you how to use them.
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
eyJoaXN0b3J5IjpbLTQzMjMzMDU5MSwxNjE2NzEzMDgxLDc3NT
A2NjA4Myw4OTUzNjY0MzAsLTE4NzYzNjM0MjUsLTkwMDQzMDM4
MywtNzg5MTYxMjY3LDE3MTI3NjUxMTQsLTE5MTYzNTU5ODIsLT
E5MTc0OTc5MTksMTkwNDEzMjk3MywyODU4MTU1NzMsNDI4Njg3
MTU5LC0xNDE0NjI4OTI3LDQ3MDMyNjM3NywxOTc5NDc0ODE4LC
0xMDQ1NDU3NjQ5LC0zNDYxNjA0NDEsNjI5MjQ3MjkzLDM4Mjk5
MzY1MV19
-->