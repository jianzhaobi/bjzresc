#' Get a list of PurpleAir sensors
#'
#' Get a list of the latest PurpleAir sensors from PurpleAir JSON (\link{https://www.purpleair.com/json}) and save as a CSV file.
#'
#' @param output.path the path of the output CSV file.
#'
#' @examples
#' getPurpleairLst('/path')
#' @export

getPurpleairLst <- function(output.path) {

  if(!require('rjson')) {
    install.packages('rjson')
    library(rjson)
  }

  # Make output path
  if(!file.exists(output.path)) {
    dir.create(output.path, recursive = T)
  }

  # Load JSON from URL
  json.file <- fromJSON(file = 'https://www.purpleair.com/json')
  # Load sensor list
  sensor.lst <- json.file$results
  # For each sensor
  sensor.df <- data.frame()
  for (i in 1 : length(sensor.lst)) {
    cat(paste('Site #:', i, '\r'))
    sensor.i.lst <- sensor.lst[[i]]
    sensor.i.lst[sapply(sensor.i.lst, is.null)] <- NA # Convert NULL to NA in order to preserve it
    sensor.i <- data.frame(t(unlist(sensor.i.lst, use.names = T)), stringsAsFactors = F)
    sensor.df <- rbind(sensor.df, sensor.i)
  }
  # Write CSV
  write.csv(sensor.df, file = paste(output.path, '/sensorlist', '_', Sys.Date(), '.csv', sep = ''), row.names = F)

}


