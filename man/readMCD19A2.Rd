\name{readMCD19A2}
\alias{readMCD19A2}
\title{Read MCD19A2 Files}
\usage{
readMCD19A2(file.name, latlong.range = NULL, border.shp = NULL)
}
\description{
Read MCD19A2 HDF files.
}
\examples{
readMCD19A2(file.name = '/path/file.HDF', latlong.range = c(132, 133, 56, 57))
readMCD19A2(file.name = '/path/file.HDF', border.shp = myshp)
}
