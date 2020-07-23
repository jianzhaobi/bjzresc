#' Get a list of PurpleAir sensors
#'
#' Get a list of the latest PurpleAir sensors from PurpleAir JSON (\link{https://www.purpleair.com/json}) and save as a CSV file.
#'
#' @param output.path the path of the output CSV file. By default, this variable equals \code{NULL} and the list is saved as a data frame.
#'
#' @return The latest PurpleAir sensor list as the data frame format
#'
#' @examples
#' # Save as a CSV file
#' getPurpleairLst('/absolute/path/to/the/csv/file')
#' # Save as a data frame variable
#' sensor.lst <- getPurpleairLst()
#' @export

getPurpleairLst <- function(output.path = NULL) {

  if(!require('jsonlite')) {
    install.packages('jsonlite')
    library(jsonlite)
  }

  if(!require('gtools')) {
    install.packages('gtools')
    library(gtools)
  }

  # Make output path
  if(!is.null(output.path) && !file.exists(output.path)) {
    dir.create(output.path, recursive = T)
  }

  # Load JSON from URL
  Sys.sleep(3) # Pause for 3 seconds to prevent HTTP Error 429
  json.file <- jsonlite::fromJSON('https://www.purpleair.com/json')
  # Load sensor list
  sensor.lst <- json.file$results
  # For each sensor
  sensor.df <- data.frame()
  for (i in 1 : length(sensor.lst)) {
    cat(paste('Site #:', i, '\r'))
    sensor.i.lst <- sensor.lst[[i]]
    sensor.i.lst[sapply(sensor.i.lst, is.null)] <- NA # Convert NULL to NA in order to preserve it
    sensor.i <- data.frame(t(unlist(sensor.i.lst, use.names = T)), stringsAsFactors = F)
    sensor.df <- gtools::smartbind(sensor.df, sensor.i) # gtools::smartbind tolerates missing columns in Channel B
  }
  # Write CSV
  if (!is.null(output.path)) {
    write.csv(sensor.df, file = paste(output.path, '/sensorlist', '_', Sys.Date(), '.csv', sep = ''), row.names = F)
  }

  return(sensor.df)

}


