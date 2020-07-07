#' Moving Average Creator
#'
#' Moving Average Creator
#'
#' @param data a vector for which the moving average is created
#' @param lag1 a non-negative integer indicating the starting lag day (lag2 > lag1)
#' @param lag2 a non-negative integer indicating the ending lag day (lag2 > lag1)
#'
#' @return A `crossbasis` matrix showing the moving average
#'
#' @examples
#' MA 0-3
#' movAvgLag(data = df$pm25, lag1 = 0, lag2 = 3)
#' @export

movAvgLag <- function(data, lag1, lag2) {
  if(!require('dlnm')) {
    install.packages('dlnm')
    library(dlnm)
  }
  if (lag1 > lag2) {
    stop('Lag 1 should be smaller than lag 2!')
  }
  crossbasis(data, lag = c(lag1, lag2), argvar = list('lin'), arglag = list("strata", df = 1))
}
