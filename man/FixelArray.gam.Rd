% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analyse.R
\name{FixelArray.gam}
\alias{FixelArray.gam}
\title{Run a GAMM4 model at each fixel location}
\usage{
FixelArray.gam(
  formula,
  data,
  phenotypes,
  scalar,
  verbose = TRUE,
  idx = NULL,
  pbar = TRUE,
  n_cores = 1,
  write = TRUE,
  ...
)
}
\arguments{
\item{formula}{Formula (passed to `gamm4()`)}

\item{data}{FixelArray dataset}

\item{phenotypes}{The cohort file with covariates to be added to the model}

\item{scalar}{The name of the scalar to be analysed fixel-wise}

\item{verbose}{Print progress messages}

\item{pbar}{Print progress bar}

\item{n_cores}{The number of cores to run on}

\item{subset}{A vector of fixel IDs to subset}
}
\value{
Tibble with the summarised model statistics at each fixel location
}
\description{
Run a GAMM4 model at each fixel location
}
