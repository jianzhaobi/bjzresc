#' Read MCD19A2 HDF-4 Files
#'
#' Read MCD19A2 HDF-4 files
#'
#' @param file.name the name of input HDF file with an \emph{absolute} path
#' @param latlong.range the lat/long range with the structure \code{c(lon.min, lon.max, lat.min, lat.max)}, cannot be used with \code{border.shp}
#' @param border.shp a shapefile (class SpatialPolygonsDataFrame), cannot be used with \code{latlong.range}
#'
#' @return A list with time stamps and MAIAC AOD data in multiple bands
#'
#' @examples
#' # Using lat/long coordinates to clip the data
#' readMCD19A2(file.name = '/path/file.HDF', latlong.range = c(132, 133, 56, 57))
#' # Using a polygon to clip the data
#' readMCD19A2(file.name = '/path/file.HDF', border.shp = myshp)
#' @export


readMCD19A2 <- function(file.name, latlong.range = NULL, border.shp = NULL) {

  if(!require('gdalUtils')) {
    install.packages('gdalUtils')
    library(gdalUtils)
  }
  if(!require('raster')) {
    install.packages('raster')
    library(raster)
  }
  if(!require('rgdal')) {
    install.packages('rgdal')
    library(rgdal)
  }

  # Check if latlong.range and border.shp exist as the same time
  if (!is.null(latlong.range) & !is.null(border.shp)) {
    stop('Cannot use `latlong.range` and `border.shp` at the same time!')
  }

  # --- Open the MCD19A2 HDF file --- #
  # Get the global attributes
  info <- gdalinfo(file.name)
  # Get the data sets
  sds <- get_subdatasets(file.name)
  # Get orbit information
  orbit.idx <- grep('Orbit_time_stamp', info)
  orbit <- info[orbit.idx] # Extract the orbit_time_stamp string
  orbit <- gsub(pattern = 'Orbit_time_stamp=', replacement = '', x = orbit) # Remove "Orbit_time_stamp="
  orbit <- unlist(strsplit(orbit, split = ' ')) # Seperate the string array by spaces
  sub.idx <- which(nchar(orbit) != 0) # Remove NA strings
  orbit <- orbit[sub.idx]

  # --- For each orbit --- #
  maiac.lst <- list()
  for (nband in 1 : length(orbit)) {

    print(paste('Band:', orbit[nband]))

    # --- Convert the data to raster --- #
    # Optical_Depth_047
    gdal_translate(sds[1], dst_dataset = paste0('tmp047', basename(file.name), '.tiff'), b = nband) # mask is band number
    # print(sds[1])
    r.047 <- raster(paste0('tmp047', basename(file.name), '.tiff'))
    # Optical_Depth_055
    gdal_translate(sds[2], dst_dataset = paste0('tmp055', basename(file.name), '.tiff'), b = nband)
    # print(sds[2])
    r.055 <- raster(paste0('tmp055', basename(file.name), '.tiff'))
    # AOD_Uncertainty
    gdal_translate(sds[3], dst_dataset = paste0('tmpuncert', basename(file.name), '.tiff'), b = nband)
    # print(sds[3])
    r.uncert <- raster(paste0('tmpuncert', basename(file.name), '.tiff'))
    # AOD_QA
    gdal_translate(sds[6], dst_dataset = paste0('tmpqa', basename(file.name), '.tiff'), b = nband)
    # print(sds[6])
    r.qa <- raster(paste0('tmpqa', basename(file.name), '.tiff'))

    # --- Convert the raster to data frame --- #
    df.047 <- raster::as.data.frame(r.047, xy = T)
    names(df.047)[3] <- 'AOD_047'
    df.055 <- raster::as.data.frame(r.055, xy = T)
    names(df.055)[3] <- 'AOD_055'
    df.uncert <- raster::as.data.frame(r.uncert, xy = T)
    names(df.uncert)[3] <- 'AOD_Uncertainty'
    df.qa <- raster::as.data.frame(r.qa, xy = T)
    names(df.qa)[3] <- 'AOD_QA'
    # Combine the data frame
    maiac.df <- data.frame(x = df.047$x, y = df.047$y, AOD_047 = df.047$AOD_047, AOD_055 = df.055$AOD_055, AOD_Uncertainty = df.uncert$AOD_Uncertainty, AOD_QA = df.qa$AOD_QA)

    # --- Delete temporary tiff files --- #
    file.remove(dir('./', paste0('tmp047', basename(file.name), '*')))
    file.remove(dir('./', paste0('tmp055', basename(file.name), '*')))
    file.remove(dir('./', paste0('tmpuncert', basename(file.name), '*')))
    file.remove(dir('./', paste0('tmpqa', basename(file.name), '*')))

    # --- Projection transformation --- #
    # SINU code
    SINU <- as.character(r.047@crs)
    # Convert projection to WGS84
    coordinates(maiac.df) <- ~x + y
    proj4string(maiac.df) <- CRS(SINU)
    maiac.df.new <- spTransform(maiac.df, CRS('+proj=longlat +datum=WGS84'))
    maiac.df.new <- as.data.frame(maiac.df.new)
    names(maiac.df.new)[(ncol(maiac.df) + 1) : (ncol(maiac.df) + 2)] <- c('Lon', 'Lat')

    # --- Cut the border --- #
    if (!is.null(latlong.range)) { # Using lat/long
      # Check if latlong.range is legal
      if (latlong.range[1] >= -180 & latlong.range[1] <= 180 & latlong.range[2] >= -180 & latlong.range[2] <= 180 &
          latlong.range[3] >= -90 & latlong.range[3] <= 90 & latlong.range[4] >= -90 & latlong.range[4] <= 90 &
          latlong.range[1] <= latlong.range[2] & latlong.range[3] <= latlong.range[4]) {

        maiac.df.sub <- subset(maiac.df.new, Lon >= latlong.range[1] &
                                 Lon <= latlong.range[2] &
                                 Lat >= latlong.range[3] &
                                 Lat <= latlong.range[4])
      } else {
        stop('Illegal lat/long ranges. Please check the value of `latlong.range`. It should be `c(lon.min, lon.max, lat.min, lat.max)`')
      }

    }
    if (!is.null(border.shp)) { # Using shapefile
      maiac.df.sub <- cutByShp(myshp = border.shp, dat = maiac.df.new, lat.name = 'Lat', long.name = 'Lon')
    }
    if (is.null(latlong.range) & is.null(border.shp)) { # Don't cut
      maiac.df.sub <- maiac.df.new
    }

    if (nrow(maiac.df.sub) > 0) {
      # --- Add Time Stamp --- #
      maiac.df.sub$Year <- as.numeric(substr(orbit[nband], start = 1, stop = 4))
      maiac.df.sub$DOY <- as.numeric(substr(orbit[nband], start = 5, stop = 7))
      maiac.df.sub$Hour <- as.numeric(substr(orbit[nband], start = 8, stop = 9))
      maiac.df.sub$Minute <- as.numeric(substr(orbit[nband], start = 10, stop = 11))
      maiac.df.sub$AOD_Type <- substr(orbit[nband], start = 12, stop = 12)

      # --- Convert QA flags --- #
      # Convert the QA string to QA flags
      qa.flags <- t(sapply(maiac.df.sub$AOD_QA, QA2Char))
      qa.flags <- as.data.frame(qa.flags)
      names(qa.flags) <- c('QA_Reserved', 'QA_Aerosolmodel', 'QA_Glintmask', 'QA_AOD', 'QA_Adjmask', 'QA_Landmask', 'QA_Cloudmask')
      maiac.df.sub <- cbind(maiac.df.sub, qa.flags)

    } else {
      maiac.df.sub$Year <- integer()
      maiac.df.sub$DOY <- integer()
      maiac.df.sub$Hour <- integer()
      maiac.df.sub$Minute <- integer()
      maiac.df.sub$AOD_Type <- factor()
      maiac.df.sub$QA_Reserved <- factor()
      maiac.df.sub$QA_Aerosolmodel <- factor()
      maiac.df.sub$QA_Glintmask <- factor()
      maiac.df.sub$QA_AOD <- factor()
      maiac.df.sub$QA_Adjmask <- factor()
      maiac.df.sub$QA_Landmask <- factor()
      maiac.df.sub$QA_Cloudmask <- factor()
    }

    maiac.df.sub <- subset(maiac.df.sub, select = c(Year, DOY, Hour, Minute, Lat, Lon, AOD_Type, AOD_047, AOD_055, AOD_Uncertainty, AOD_QA,
                                                    QA_Reserved, QA_Aerosolmodel, QA_Glintmask, QA_AOD, QA_Adjmask, QA_Landmask, QA_Cloudmask))

    # --- Construct the MAIAC AOD list --- #
    maiac.lst[[nband]] <- list(time.stamp = orbit[nband],
                               maiac.data = maiac.df.sub)

  }
  return(maiac.lst)
}
