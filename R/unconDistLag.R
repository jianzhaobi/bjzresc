#' Unconstrained Distributed Lag Creator
#'
#' Unconstrained Distributed Lag Creator
#'
#' @param data a vector for which the distributed lag is created
#' @param lag1 a non-negative integer indicating the starting lag day (lag2 > lag1)
#' @param lag2 a non-negative integer indicating the ending lag day (lag2 > lag1)
#'
#' @return A `crossbasis` matrix showing the distributed lag
#'
#' @examples
#' # Lag 0-3
#' unconDistLag(data = df$pm25, lag1 = 0, lag2 = 3)
#' @export

unconDistLag <- function(data, lag1, lag2) {
  if(!require('dlnm')) {
    install.packages('dlnm')
    library(dlnm)
  }
  if (lag1 > lag2) {
    stop('Lag 1 should be smaller than lag 2!')
  }
  crossbasis(data, lag = c(lag1, lag2), argvar = list('lin'), arglag = list('integer'))
}
