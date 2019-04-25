#' Download Purple Air PM2.5 data
#'
#' Download Purple Air PM2.5 data and save as csv files (each PurpleAir site per file). The indoor sites are not included by default.
#'
#' @param site.csv a data frame of a site list or a absolute path to the site CSV file (from \code{getPurpleairLst}).
#' @param start.date the beginning date in the format "YYYY-MM-DD".
#' @param end.date the end date in the format "YYYY-MM-DD".
#' @param output.path the path to output CSV files.
#' @param average get average of this many minutes, valid values: 10, 15, 20, 30, 60, 240, 720, 1440, "daily". "daily" is not recommended as the daily values can only be calculated at the UTC time.
#' @param time.zone time zone specification to be used for the conversion, but "" is the current time zone, and "GMT" is UTC (Universal Time, Coordinated). Invalid values are most commonly treated as UTC, on some platforms with a warning. For more time zones, see \link{https://www.mathworks.com/help/thingspeak/time-zones-reference.html}.
#' @param indoor whether includes indoor sites (FALSE by default).
#' @param n.thread number of parallel threads used to download the data (1 by default).
#'
#' @examples
#' purpleairDownload(site.csv = '/absolute/path/to/the/sensorlist.csv',
#'     start.date = '2017-01-01',
#'     end.date = '2017-12-31',
#'     output.path = '/output_path',
#'     average = 60,
#'     time.zone = 'America/Los_Angeles')
#' @export


purpleairDownload <- function(site.csv, start.date, end.date, output.path, average, time.zone = 'GMT', indoor = F, n.thread = 1) {

  if (!require('httpuv')) {
    install.packages('httpuv')
    library(httpuv)
  }
  if (!require('foreach')) {
    install.packages('foreach')
    library(foreach)
  }
  if (!require('doMC')) {
    install.packages('doMC')
    library(doMC)
  }
  registerDoMC(n.thread)

  # Read the lastest sensor list
  if (class(site.csv) == 'data.frame') {
    sites <- site.csv
  } else if (class(site.csv) == 'character') {
    sites <- read.csv(site.csv, as.is = T)
  } else {
    stop('Illegal CSV variable name!')
  }

  # Start date and end date
  start_date <- as.Date(start.date)
  end_date <- as.Date(end.date)

  # Output directory
  out.path <- output.path
  if (!file.exists(out.path)) {
    dir.create(out.path, recursive = T)
  }

  # Time zone
  timezone <- time.zone

  # Average level
  # Don't use 'daily' since the time is UTC !!!
  average <- average

  # Field names
  # Primary
  fieldnames.pri.A <- c("PM1.0_CF_ATM_ug/m3_A","PM2.5_CF_ATM_ug/m3_A","PM10.0_CF_ATM_ug/m3_A","Uptime_Minutes_A","RSSI_dbm_A","Temperature_F_A","Humidity_%_A","PM2.5_CF_1_ug/m3_A")
  fieldnames.pri.B <- c("PM1.0_CF_ATM_ug/m3_B","PM2.5_CF_ATM_ug/m3_B","PM10.0_CF_ATM_ug/m3_B","HEAP_B","ADC0_voltage_B","Atmos_Pres_B","Not_Used_B","PM2.5_CF_1_ug/m3_B")
  # Secondary
  # fieldnames.sec <- c("0.3um/dl","0.5um/dl","1.0um/dl","2.5um/dl","5.0um/dl","10.0um/dl","PM1.0_CF_1_ug/m3","PM10_CF_1_ug/m3")

  #--------------Run--------------#
  # For each site
  foreach (i = 1 : nrow(sites)) %dopar% {

    if (!file.exists(file.path(out.path, paste(sites$ID[i], '.csv', sep = '')))) { # Skip existing files
      if ((is.na(sites$ParentID[i])) & (!is.na(sites$DEVICE_LOCATIONTYPE[i]))) { # Skip Channel B sensors
        if (indoor | sites$DEVICE_LOCATIONTYPE[i] == 'outside') { # Skip indoor sensors

          # --- Site information ---
          name <- trimws(sites$Label[i]) # Remove Leading/Trailing Whitespace
          Lat <- sites$Lat[i]
          Lon <- sites$Lon[i]
          # Channel A
          ID.A <- sites$ID[i]
          channelID.A <- sites$THINGSPEAK_PRIMARY_ID[i]
          channelKey.A <- sites$THINGSPEAK_PRIMARY_ID_READ_KEY[i]
          # Channel B
          ib <- which(sites$ParentID == ID.A)
          if (length(ib) > 1) { # If there are multiple Channel B
            ib.min <- ib[which(sites$AGE[ib] == min(sites$AGE[ib]))]
            ib.min <- ib.min[1] # If there are multiple channel B with the same AGE, select the first one
            channelID.B <- sites$THINGSPEAK_PRIMARY_ID[ib.min]
            channelKey.B <- sites$THINGSPEAK_PRIMARY_ID_READ_KEY[ib.min]
          } else {
            channelID.B <- sites$THINGSPEAK_PRIMARY_ID[ib]
            channelKey.B <- sites$THINGSPEAK_PRIMARY_ID_READ_KEY[ib]
          }

          print(ID.A)

          # --- Channel A & B ---
          # Initialization of primary data frame
          dat.final <- data.frame()

          for (j in 0 : as.numeric(end_date - start_date)) {

            this.day <- start_date + j
            cat(as.character(this.day), '\r')

            # --- Time range for a day ---
            starttime <- httpuv::encodeURI(paste(this.day, '00:00:00')) # UTC Time !!!
            endtime <- httpuv::encodeURI(paste(this.day, '23:59:59')) # UTC Time !!!

            # --- URL ---
            # Channel A
            url.csv.A <- paste("https://thingspeak.com/channels/", channelID.A, "/feed.csv?api_key=", channelKey.A, '&average=', average, "&round=3&start=", starttime, "&end=", endtime, '&timezone=', timezone, sep = '')
            # Channel B
            url.csv.B <- paste("https://thingspeak.com/channels/", channelID.B, "/feed.csv?api_key=", channelKey.B, '&average=', average, "&round=3&start=", starttime, "&end=", endtime, '&timezone=', timezone, sep = '')

            # --- Load CSV data ---
            # Download URL A
            url.idx <- T
            while (url.idx) {
              try.txt <- try(expr = { # Try to connect the link
                dat.A <- read.csv(url.csv.A)
              }, silent = T)
              closeAllConnections()
              if (!inherits(try.txt, 'try-error')) url.idx <- F
            }

            if (length(ib) != 0) { # If Channel B exists
              # Download URL B
              url.idx <- T
              while (url.idx) {
                try.txt <- try(expr = { # Try to connect the link
                  dat.B <- read.csv(url.csv.B)
                }, silent = T)
                closeAllConnections()
                if (!inherits(try.txt, 'try-error')) url.idx <- F
              }
            } else {
              dat.B <- dat.A
              if (nrow(dat.B) != 0) {
                dat.B[,] <- NA
                dat.B$created_at <- dat.A$created_at
              }
            }
            # Combine Channel A & B
            dat <- merge(dat.A, dat.B, by = c('created_at'), all = T)
            # Change the column names
            names(dat)[2 : ncol(dat)] <- c(fieldnames.pri.A, fieldnames.pri.B)

            # --- Combine data frame ---
            dat.final <- rbind(dat.final, dat)

          }

          # --- Add basic information --- #
          if (nrow(dat.final) != 0) {
            dat.final$ID <- ID.A
            dat.final$Name <- name
            dat.final$Lat <- Lat
            dat.final$Lon <- Lon
          }

          # --- Save CSV data ---
          file.name <- paste(ID.A, '.csv', sep = '')
          write.csv(dat.final, file.path(out.path, file.name), row.names = F)

        } # if
      } # if
    } # if

  }
  #--------------Run--------------#

}






