% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mod_convert.R
\name{convert_dataset}
\alias{convert_dataset}
\alias{convert_dataset_ui}
\alias{convert_dataset_server}
\title{infos_dataset_ui and infos_dataset_server}
\usage{
convert_dataset_ui(id)

convert_dataset_server(
  id,
  reset = reactive({
     NULL
 }),
  is.enabled = reactive({
     TRUE
 })
)

convert_dataset()
}
\arguments{
\item{id}{shiny id}

\item{obj}{An instance of the class \code{QFeatures}.}
}
\value{
A shiny app
}
\description{
A shiny Module.
}
\examples{
\dontrun{
library(MagellanNTK)
library(Prostar2)
library(DaparToolshed)
data(Exp1_R25_prot, package = 'DaparToolshedData')
shiny::runApp(convert_dataset())
}

}
\keyword{internal}
