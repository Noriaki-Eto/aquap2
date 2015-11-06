#' @rdname plot
#' @template mr_whatPlotSubtypes
#' @export
plot_cube <- function(x, what="all", ...) {
	autoUpS()
	pv <- pv_what_subPlots 			# c("all", "pca", "sim", "pls", "aqg")
	if (!all(what %in% pv)) {
		stop(paste("Please provide one or more of \n'", paste(pv, collapse="', '"), "' \nto the argument 'what'.", sep=""), call.=FALSE)
	}
	if (any(c(pv[1], pv[2]) %in% what)) { # PCA
		plot_pca(x, ...)
	}
	if (any(c(pv[1], pv[3]) %in% what)) { # SIMCA
		plot_sim(x, ...)	
	}
	if (any(c(pv[1], pv[4]) %in% what)) { # PLSR
		plot_pls(x, ...)
	}
	if (any(c(pv[1], pv[5]) %in% what)) { # Aquagram
		plot_aqg(x, ...)
	}
	invisible(NULL)
} # EOIF


#' @title Plot - General Plotting  Arguments
#' @description The following parameters can be used in the \code{...} argument in 
#' any of the plotting-functions (see \code{\link{plot}}) to override the values 
#' in the analysis procedure file and so to modify the graphics / the pdf - see 
#' examples.
#' 
#' \code{plot(cube, ...)}
#' 
#' \code{plot_cube(cube, ...)}
#' 
#' @template mr_details_allParams
#' @template mr_pg_genParams
#' @examples
#' \dontrun{
#' dataset <- gfd()
#' cube <- gdmm(dataset)
#' plot(cube, pg.main="Foo") 
#' # prints an additional "Foo" on the title of each plot.
#' plot(cube, pg.main="Foo", pg.fns="_foo")
#' # adds the string "_foo" to each of the generated pdfs.
#' }
#' @family Plot arguments
#' @name plot_pg_args
#' NULL
