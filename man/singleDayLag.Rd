% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/singleDayLag.R
\name{singleDayLag}
\alias{singleDayLag}
\title{Single-Day Lag Creator}
\usage{
singleDayLag(data, lag)
}
\arguments{
\item{data}{a vector for which the single-day lag is created}

\item{lag}{a non-negative integer indicating the lag day}
}
\value{
A `crossbasis` matrix showing the single-day lag
}
\description{
Single-Day Lag Creator
}
\examples{
# Lag 1
singleDayLag(data = df$pm25, lag = 1)
}
