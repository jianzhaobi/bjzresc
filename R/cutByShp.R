#' Clip A Data Frame by A Shapefile
#'
#' Clip a data frame by a shapefile
#'
#' @param myshp the shapefile (class SpatialPolygonsDataFrame) that must be based on WGS84 coordinate system
#' @param dat the data frame to be cut that must include WGS84 lat/long coordinates
#' @param lat.name the name of the column about latitude in \code{dat}
#' @param long.name the name of the column about longitude in \code{dat}
#'
#' @return A subset of the data frame clipped by the shapefile
#'
#' @examples
#' cutByShp(myshp = shp, dat = df, lat.name = 'Lat', long.name = 'Lon')
#' @export

cutByShp <- function(myshp, dat, lat.name, long.name) {

  if(!require('sp')) install.packages('sp')
  if(!require('raster')) install.packages('raster')

  # Change the lat/long names to 'x' and 'y'
  lat.idx <- grep(lat.name, colnames(dat))
  long.idx <- grep(long.name, colnames(dat))
  colnames(dat)[c(long.idx, lat.idx)] <- c('x', 'y')

  # Subset the data frame by bbox
  dat <- subset(dat, x >= myshp@bbox[1, 1] &
                  x <= myshp@bbox[1, 2] &
                  y >= myshp@bbox[2, 1] &
                  y <= myshp@bbox[2, 2])

  # Clip
  if (nrow(dat) > 0) { # check if the subset has any element
    # Convert the data set to spatial data
    coordinates(dat) <- ~ x + y
    proj4string(dat) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

    # Clip the data frame
    clip <- over(dat, myshp)
    idx_clip <- is.na(clip[, 1])
    dat <- as.data.frame(dat, stringsAsFactors = F)
    dat.sub <- dat[!idx_clip, ]

  } else {

    dat.sub <- dat

  }

  # Change back to the original lat/long name
  colnames(dat.sub)[c(long.idx, lat.idx)] <- c(long.name, lat.name)

  return(dat.sub)

}
