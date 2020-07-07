#' Single-Day Lag Creator
#'
#' Single-Day Lag Creator
#'
#' @param data a vector for which the single-day lag is created
#' @param lag a non-negative integer indicating the lag day
#'
#' @return A `crossbasis` matrix showing the single-day lag
#'
#' @examples
#' # Lag 1
#' singleDayLag(data = df$pm25, lag = 1)
#' @export

singleDayLag <- function(data, lag) {
  if(!require('dlnm')) {
    install.packages('dlnm')
    library(dlnm)
  }
  crossbasis(data, lag = c(lag, lag), argvar = list('lin'), arglag = list('integer'))
}

