% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_all.r
\name{plot_pg_args}
\alias{plot_pg_args}
\title{Plot - General Plotting  Arguments}
\arguments{
\item{pg.where}{Character length one. If left at the default 'def', the value 
from the settings.r file is read in (parameter \code{gen_plot_pgWhereDefault}). 
For plotting to PDFs provide "pdf", for plotting to graphics device provide 
anything but "pdf".}

\item{pg.main}{Character length one. The additional text on the title of each 
single plot.}

\item{pg.sub}{Character length one. The additional text on the subtitle of 
each single plot.}

\item{pg.fns}{Character length one. The additional text in the filename of 
the pdf.}
}
\description{
The following parameters can be used in the \code{...} argument in 
any of the plotting-functions (see \code{\link{plot}}) to override the values 
in the analysis procedure file and so to modify the graphics / the pdf - see 
examples.

\code{plot(cube, ...)}

\code{plot_cube(cube, ...)}

\code{plot(dataset, ...)}

\code{plot_spectra(dataset, ...)}

\code{plot_spectra(cube, ...)}
}
\details{
For a list of all parameters that can be used in the \code{...} 
argument in \code{\link{getap}} and in the \code{\link{plot}} functions 
please see \code{\link{anproc_file}}.
}
\examples{
\dontrun{
dataset <- gfd()
cube <- gdmm(dataset)
plot(cube, pg.main="Foo") 
# prints an additional "Foo" on the title of each plot.
plot(cube, pg.main="Foo", pg.fns="_foo")
# adds the string "_foo" to each of the generated pdfs.
}
}
\seealso{
Other Plot arguments: \code{\link{plot,aquap_data,missing-method}},
  \code{\link{plot_NNET_args}},
  \code{\link{plot_SVM_args}}, \code{\link{plot_aqg_args}},
  \code{\link{plot_discrimAnalysis_args}},
  \code{\link{plot_pca_args}}, \code{\link{plot_pls_args}},
  \code{\link{plot_randomForest_args}},
  \code{\link{plot_sim_args}}
}
\concept{Plot arguments}
