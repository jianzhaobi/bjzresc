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

  # Make output path
  if(!is.null(output.path) && !file.exists(output.path)) {
    dir.create(output.path, recursive = T)
  }

  # Load JSON from URL
  idx <- T
  while(idx) {
    tryCatch(expr = {
      Sys.sleep(2) # Pause for 2 seconds to prevent HTTP Error 429
      json.file <- jsonlite::fromJSON('http://www.purpleair.com/json?tempAccess=UniversityofWashingtonSeattle')
      idx <- F
    },
    error = function(e) {
      # print(e)
      Sys.sleep(2)
      idx <- T
    })
  }

  # Load sensor list
  sensor.df <- json.file$results
  # Write CSV
  if (!is.null(output.path)) {
    write.csv(sensor.df, file = paste(output.path, '/sensorlist', '_', Sys.Date(), '.csv', sep = ''), row.names = F)
  }

  return(sensor.df)

}


