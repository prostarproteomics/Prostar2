% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mod_mv_plots.R
\name{mod_mv_plots}
\alias{mod_mv_plots}
\alias{mod_mv_plots_ui}
\alias{mod_mv_plots_server}
\title{xxx}
\usage{
mod_mv_plots_ui(id)

mod_mv_plots_server(
  id,
  data = reactive({
     NULL
 }),
  grp = reactive({
     NULL
 }),
  mytitle = NULL,
  pal = reactive({
     NULL
 }),
  pattern,
  is.enabled = reactive({
     TRUE
 }),
  remoteReset = reactive({
     NULL
 })
)

mod_mv_plots(data, title = NULL, pal = NULL, pattern = NULL)
}
\arguments{
\item{data}{xxx}

\item{pal}{xxx}

\item{pattern}{xxx}

\item{title}{xxx}

\item{...}{xxx}
}
\description{
xxx
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
data(Exp1_R25_prot, package = 'DaparToolshedData')
shiny::runApp(mod_mv_plots(Exp1_R25_prot[[1]]))
\dontshow{\}) # examplesIf}
}
