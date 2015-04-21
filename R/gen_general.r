#  @title Show Path to Package Aquap2
#  @description Displays a character string with the path to the packae 
#    'Aquap2'
#  @details This is where you can find the source of the 
#  \code{\link{settings_file}}.
#  @return A character string with the path.
#  @family Helper Functions
#  @export
showPathToAquap2 <- function() {
	path <- path.package("aquap2")
	cat("The path to this package is: \n")
	print(path)
	cat("(This is where you will find the settings.r file.\n")
	invisible(path)
} # EOF

copySettingsFile <- function(fromPath, toPath) {
	a <- paste(toPath, "settings.r", sep="/")
	b <- paste(toPath, "settings_OLD.r", sep="/")
	if (file.exists(a)) {
		file.rename(a, b)
	}
	ok <- file.copy(fromPath, toPath, overwrite=TRUE)
	if (ok) { cat("A fresh version of the settings.r file has been copied from the package.\n")}			
} # EOF

checkSettings <- function() {
	pspath <- paste(path.package("aquap2"), "/settings.r", sep="")
	pathSH <- Sys.getenv("AQUAP2SH")
	if (nchar(pathSH) == 0) { 			## so the variable is *not* defined in .Renviron
		homePath <- "user/home"
		hp <- try(path.expand("~"), silent=TRUE)
		if (class(hp) != "try-Error") {
			homePath <- hp
		}
		homePath <- paste(homePath, "/.Renviron", sep="")
		msg <- paste("It appears you did not yet define the path to your aquap2 settings.r home directory in the '.Renviron' file. \nPlease do this by going to the .Renviron file (in your home directory '", homePath, "') and there define the variable 'AQUAP2SH' as the path to a folder of your liking. \nIf you do not have a '.Renviron' file you have to create one. (You can do this conveniently e.g. with R-Studio by creating a new R-script and saving it under '", homePath, "')\nRestart R for the changes to become effective. \nSee the help for '?updateSettings' for additional information", sep="")
		message(msg)
		return(FALSE)
	} else { ## so we have something defined under AQUAP2SH
		if (!file.exists(pathSH)) {
			msg <- paste("The folder \"", pathSH, "\" does not seem to exist. Please check the path defined in the '.Renviron' file. Thanks.", sep="")
			message(msg)
			return(FALSE)
		}
		sFile <- "/settings.r"
		pathToSettings <- paste(pathSH, sFile, sep="")
		if (!file.exists(pathToSettings)) {
			msg <- paste("The required settings.r file does not seem to exist in the provided directory \n\"", pathSH, "\".\nWould like to copy a factory-fresh version of the settings.r file there now? \n( y / n)", sep="")
			message(msg)
			a <- readLines(n=1)
			if (a != "y" & a != "Y") {
				msg <- paste("Please see to it that a valid settings.r file will be in the directory shown above.")
				message(msg)
				return(FALSE)
			} else {  # so we do want to copy the file
				copySettingsFile(pspath, pathSH)
				return(TRUE)
			}
		} else { ## so the file does exist
			loc <- pathToSettings
			pac <- pspath
			fenv <- new.env()
			source(loc, local=fenv)
			locNames <- names(fenv$stn)
			source(pac, local=fenv)
			pacNames <- names(fenv$stn)
			if (!identical(locNames, pacNames)) {
				okInd <- which(pacNames %in% locNames)
				miss <- pacNames[-okInd]
				delInd <- which(locNames %in% pacNames)
				del <- locNames[-delInd]
				msgNew <- "The new variables are:"
				msgDel <- "The following variables have been deleted:"
				#
				message("There appears to be a newer version of the settings.r file in the package \"aquap2\".")
				if (length(miss) != 0 & length(del) == 0) {
					message(msgNew) ;   message(paste(miss, collapse=", "))
				} else {
					if (length(miss) == 0 & length(del) != 0) {
						message(msgDel); 	message(paste(del, collapse=", "))
					} else {
						message(msgNew) ;   message(paste(miss, collapse=", "))
						message(msgDel); 	message(paste(del, collapse=", "))
					}
				}
				message(paste("Do you want to copy it now into \n\"", pathSH, "\" ? \nThe existing file will remain in place but will be renamed to 'settings_OLD.r' \n( y / n )", sep=""))
				a <- readLines(n=1)
				if (a != "y" & a != "Y") {
					message("Please be aware that the package will not work properly if your settings.r file is not up to date.")
					return(FALSE)
				} else {
					copySettingsFile(pspath, pathSH)
					return(TRUE)
				}
			} else { 	# so the variable names in the two settings files are identical
				return(TRUE)
			} 	
		} # end else file exists
	} # end else nchar == 0
} # EOF

#' @title Update aquap2 settings.
#' @description Manually read in the settings-file in the aquap2-settings 
#' home directory as specified in the .Renviron file.
#' @details If you leave 'autoUpdateSettings' in settings.r to 'TRUE', the 
#' settings will be checked resp. updated automatically every time you call any 
#' function from package 'aquap2'.
#' @section Note: You have to set the path to where you want the settings.r file 
#' to be stored once in your .Renviron file by defining 
#' \code{AQUAP2SH = path/to/any/folder/XX} , with XX being any folder where then the 
#' settings.r file will reside in. If you do not have a '.Renviron' file in your 
#' home directory (user/home) you have to create one.
#' @param packageName Character, the name of the package where settings 
#' should be updated. Defaults to "aquap2".
#' @param silent Logical. If a confirmation should be printed. Defaults 
#' to 'FALSE'
#' @return An (invisible) list with the settings resp. a list called 'stn' in 
#' the environment '.ap2'.
#' @family Helper Functions
#' @seealso \code{\link{settings_file}} 
#' @examples
#' \dontrun{
#' updateSettings()
#' str(.ap2$stn)
#' ls(.ap2)
#'}
#' @export
updateSettings <- function(packageName="aquap2", silent=FALSE) { 
	ok <- checkSettings() # makes sure that we have the latest version of the settings.r file in the settings-home directory defined in .Renviron
	if (ok) {
		pathSettings <- paste(Sys.getenv("AQUAP2SH"), "/settings.r", sep="")
		sys.source(pathSettings, envir=.GlobalEnv$.ap2)
	#	if (any(grepl(".ap2", search(), fixed=TRUE))) {
	#		detach(.ap2)
	#	}
	#	attach(.ap2)
		if (!silent) {
			cat(paste(packageName, "settings updated\n"))
		}
		invisible(.ap2$stn)
	} else { # so if the settings check was not ok
	return(invisible(NULL))
	}
} # EOF

autoUpS <- function() { # stops if somethings goes wrong
	res <- 1
	if (exists(".ap2$stn")) {
		autoUpS <- .ap2$stn$autoUpdateSettings
	} else {
		autoUpS <- TRUE
	}
	if (autoUpS) {
		if (is.null(.ap2$.devMode)) { 			## to be able to run it locally without loading the package
			res <- updateSettings(packageName="aquap2", silent=TRUE)
		}
	}
	if (is.null(res)) {
	stop(call.=FALSE)
	}
} # EOF

#' @title Generate Folder Structure
#' @description Generate the required folder structure in the current working 
#' directory.
#' @details \code{genFolderStr} will generate all the required folders in the 
#' current working directory that 'aquap2' needs to work properly. Templates 
#' for metadata and analysis procedure will be copied into the metadata-folder.
#' You can change the defaults for the folder names in the settings file.
#' @return Folders get created in the current working directory.
#' @family Helper Functions
#' @seealso \code{\link{settings_file}} 
#' @export
genFolderStr <- function() {
	autoUpS()
	fn_analysisData <- .ap2$fn_analysisData 
	fn_exports <- .ap2$stn$fn_exports
	fn_rcode <- .ap2$stn$fn_rcode 
	fn_rawdata <- .ap2$stn$fn_rawdata
	fn_rdata <- .ap2$stn$fn_rdata 
	fn_metadata <- .ap2$stn$fn_metadata
	fn_results <- .ap2$stn$fn_results 
	fn_sampleLists <- .ap2$stn$fn_sampleLists
	fn_sampleListOut <- .ap2$stn$fn_sampleListOut
	f_sampleListIn <- .ap2$stn$f_sampleListIn
	
	fn_mDataDefFile <- .ap2$stn$fn_mDataDefFile
	fn_anProcDefFile <- .ap2$stn$fn_anProcDefFile
	pp <- c(fn_analysisData, fn_exports, fn_rcode, fn_rawdata, fn_rdata, fn_metadata, fn_results, fn_sampleLists)
	dirOk <- NULL
	for (p in pp) {
		dirOk <- c(dirOk, dir.create(p))
	}
	slin <- paste(fn_sampleLists, f_sampleListIn, sep="/")
	slout <- paste(fn_sampleLists, fn_sampleListOut, sep="/")
	dirOk <- c(dirOk, dir.create(slin))
	dirOk <- c(dirOk, dir.create(slout))
	a <- path.package("aquap2")
	pathFrom <- paste(a, "/templates/", sep="")
	pathFromMeta <- paste(pathFrom, fn_mDataDefFile, sep="")
	pathFromAnP <- paste(pathFrom, fn_anProcDefFile, sep="")
	file.copy(pathFromMeta, fn_metadata)
	file.copy(pathFromAnP, fn_metadata)
	if (any(dirOk)) {
		if (!.ap2$stn$allSilent) {	cat("Folder structure created.\n")}
	} 
} # EOF


#'  @title Update the aquap2-package.
#'  @description Download and install the latest version of package 'aquap2' 
#'  from its github repository
#'  @details Always downloads and installs the latest available version, also 
#'  if the same up-to-date version is already installed.
#'  @param branch Character, the name of the branch to downlaod. Defaults to 
#'  "master".
#'  @family Helper Functions
#'  @examples
#'  \dontrun{
#'  updateAquap()
#'  }
#'  @export
updateAquap <- function(branch="master") {
	github_pat <- "c4818f3957df95d831de2bd36ac7ce46ad3ad340"
	devtools::install_github(repo="bpollner/aquap2", ref=branch, auth_token=github_pat, build_vignettes=TRUE)
} # EOF


#'  @title Load the aquap2 data and examples package.
#'  @description Download and install the latest version of package 'aquapData' 
#'  from its github repository. 
#' 	Package 'aquapData' contains the data and examples used in package 'aquap2'.
#'  @details Always downloads and installs the latest available version, also 
#'  if the same up-to-date version is already installed.
#'  @param branch Character, the name of the branch to downlaod. Defaults to 
#'  "master".
#'  @examples
#'  \dontrun{
#'  loadAquapDatapackage()
#'  }
#'  @export
loadAquapDatapackage <- function(branch="master") {
	github_pat <- "26728e1a8199df859170a83fc4025f8a34deb25b"
	devtools::install_github(repo="bpollner/aquapData", ref=branch, auth_token=github_pat)
} # EOF

getStdColnames <- function() {
	yPref <- .ap2$stn$p_yVarPref
	cPref <- .ap2$stn$p_ClassVarPref
	sampleNrColn <- .ap2$stn$p_sampleNrCol
	conSNrColn <- .ap2$stn$p_conSNrCol
	timePointsColn <- .ap2$stn$p_timeCol
	ecrmColn <- .ap2$stn$p_ECRMCol
	replColn <- .ap2$stn$p_replicateCol
	groupColn <- .ap2$stn$p_groupCol
	tempColn <- .ap2$stn$p_tempCol
	relHumColn <- .ap2$stn$p_RHCol
	stdColsY <- c(paste(yPref, sampleNrColn, sep=""), paste(yPref, conSNrColn, sep=""), paste(yPref, tempColn, sep=""), paste(yPref, relHumColn, sep=""))
	stdColsC <- c( paste(cPref, timePointsColn, sep=""), paste(cPref, ecrmColn, sep=""), paste(cPref, replColn, sep=""), paste(cPref, groupColn, sep=""))
	return(list(stdColsY=stdColsY, stdColsC=stdColsC))
} # EOF

#' @title Print standard column names
#' @description Prints the standard column names as defined in the local 
#' settings.r file to stdout.
#' @family Helper Functions
#' @export
printStdColnames <- function() {
	autoUpS()
	cns <- getStdColnames()
	stdColsC <- cns$stdColsC
	stdColsY <- cns$stdColsY
	cat("The standard column names as defined in your settings.r file are: \n\n")
	cat("Class variables:\n")
	cat(paste(stdColsC, collapse=", ")); cat("\n\n")
	cat("Numeric variables:\n")
	cat(paste(stdColsY, collapse=", ")); cat("\n")
} # EOF


#' @title Install Examples
#' @description Install a single experiment-home folder containing various 
#' examples.
#' @details The example folder will be installed in the directory as specified 
#' in the .Renviron file. (see \code{\link{updateSettings}})
#' @family Helper Functions
#' @export
instAquap2Examples <- function() {
	eh <- "home_examples"
	pathSH <- Sys.getenv("AQUAP2SH")
	pathFolder <- paste(pathSH, "/", eh, sep="")
	a <- system.file(package="aquap2")
	pathFrom <- paste(a, "/", eh, sep="")
	ok <- FALSE
	if (!file.exists(pathFolder)) {
		ok <- file.copy(pathFrom, pathSH, recursive=TRUE)
		
	}
	if (ok) {cat("Example folder copied\n")}
} # EOF


getWavelengths <- function(dataset) {
	a <- colnames(dataset$NIR)
	ncpwl <- getNcpwl(dataset)
	wls <- as.numeric(substr(a, 1+ncpwl, nchar(a)))
	return(wls)	
} # EOF

#' @title Select Observations
#' @description Create includes or excludes from the dataset by selecting 
#' from any variable in any logical combination, using the available logical 
#' operators like e.g. '|' and '&'.
#' @details The column names are provided as is, i.e. without quotes, while for 
#' characters the values have to be enclosed in quotation marks - see examples.
#' @param dataset An object of class 'aquap_data'
#' @param criteria The selection criteria in the format 
#' \code{variableName == value}, possibly joined by logical operators.
#' @param include Logical. If the observations matching the criteria should be 
#' included or excluded from the dataset.
#' @param keepEC If *all* the environmental control observations should be kept 
#' in the dataset. Only evaluated if 'include' is TRUE.
#' @return The standard dataset as described in \code{\link{getFullData}}
#'  @examples
#'  \dontrun{
#'  ds <- ssc(dataset, C_Group=="Control")
#'  # keeps all the controls
#'  ds <- ssc(dataset, C_Group!="Control", include=FALSE)
#'  # the same as above
#'  
#'  
#'  ds <- ssc(dataset, C_Group=="Control" & C_Repl=="R1")
#'  # keeps only the first replicate of the controls
#'  ds <- ssc(dataset, C_Group=="Control" | C_Repl=="R1")
#'  # keeps all the first replicate and all the controls
#'  
#'  
#'  ds <- ssc(dataset, C_Group=="Control" & C_Repl=="R1", keepEC=TRUE)
#'  # keeps the first replicate of the controls and all the environmental controls
#'  ds <- ssc(dataset, C_Group=="Control" & C_Repl=="R1", include=FALSE)
#'  # keeps everything except the first replicate of the controls
#'  
#'  
#'  ds <- ssc(dataset, (C_Group=="Control" | C_Group=="Treatment") & Y_conSNr==1)
#'  # keeps the first consec. scan of the controls and the treatment group.
#'  ds <- ssc(dataset, (C_Group=="Control" | C_Group=="MQ") & C_conSNr=="1")
#'  # keeps the first consec. scan of the controls and the environmental controls
#'  
#'  
#'  ds <- ssc(dataset, Y_Temp==22.5)
#'  ds <- ssc(dataset, Y_Temp==22.5 & Y_conSNr==1)
#'  ds <- ssc(dataset, Y_conSNr==1) 
#'  # keeps only the first consecutive scan
#'  }
#' @family Data pre-treatment functions
#' @export
ssc <- function(dataset, criteria, include=TRUE, keepEC=FALSE) {
	cPref <- .ap2$stn$p_ClassVarPref
	ecrmCol <- .ap2$stn$p_ECRMCol
	ecLabel <- .ap2$stn$p_envControlLabel
	string <- deparse(substitute(criteria))
	cns <- colnames(dataset$header)
	cnsPres <- cns[which(lapply(cns, function(x) grep(x, string)) > 0)] # gives back only those column names that appear in the string
	stri <- string
	for (i in 1: length(cnsPres)) {
		stri <- gsub(cnsPres[i], paste("dataset$header$", cnsPres[i], sep=""), stri)
	}
	if (include) {
		if (keepEC) {
			stri <- paste("(", stri, ") |  dataset$header$", cPref, ecrmCol, " == \"", ecLabel, "\"", sep="")
		}
		d <- dataset[which(eval(parse(text=stri))),]
	} else {
		d <- dataset[-(which(eval(parse(text=stri)))),]
	}
	if (nrow(d) == 0) {
		stop(paste("Your selection criteria yielded no results. Please check your input."), call.=FALSE)
	}
#	return(new("aquap_data", reFactor(d)))
	return(d)
} # EOF

# to be called from the system
ssc_s <- function(dataset, variable, value, keepEC=FALSE) {
	# variable and value are always data frames with one row and 1 or *more* columns
	cPref <- .ap2$stn$p_ClassVarPref
	ecrmCol <- .ap2$stn$p_ECRMCol
	ecLabel <- .ap2$stn$p_envControlLabel
	noSplitCol <- paste(cPref, .ap2$stn$p_commonNoSplitCol, sep="")
	indEC <- which(colnames(dataset$header) == paste(cPref, ecrmCol, sep=""))
	selIndOut <-  NULL
	#
	getECInd <- function(variable) { # because we must not add the ec´s if they are already present in the case of the no-split column
		nsc <- any(noSplitCol %in% variable)
		if (keepEC & !nsc) {
			return(which(dataset$header[,indEC] == ecLabel))
		} else {
			return(NULL)
		}
	} # EOIF
	###
	if (class(variable) == "data.frame") {
		for (i in 1: ncol(variable)) { # both variable and value have the same number of columns
			ind <- which(colnames(dataset$header) == variable[1,i])
			val <- as.character(value[1,i])
			selInd <-  which(dataset$header[,ind] == val)
			if (length(selInd) == 0) {
				return(NULL)	
			}
			selIndOut <- c(selInd, selIndOut)
		} # end for i
		selIndEC <- getECInd(variable[1,])
	} else {
		ind <- which(colnames(dataset$header) == variable)
		val <- as.character(value)
		selIndOut <-  which(dataset$header[,ind] == val)
		if (length(selIndOut) == 0) {
			return(NULL)	
		}
		selIndEC <- getECInd(variable)	
	}	
	return(dataset[c(selIndOut, selIndEC),])
} # EOF


reFactor <- function(dataset) {
	for (i in 1: ncol(dataset$header)) {
		if (is.factor(dataset$header[,i])) {
			dataset$header[i] <- factor(dataset$header[,i])
		}
	}
	return(dataset)
} # EOF


is.wholenumber <- function(x, tol = .Machine$double.eps^0.5) {
	 return(abs(x - round(x)) < tol)
} # EOF


makePchSingle<- function(PchToReFact, extra = FALSE) {  #PchToReFact: the factor what you want to display with different pch, extra: additional not nice pch
	nr <- length(unique(PchToReFact))
 	if (extra) {
 		nicePch<-c(0:20,35,127,134,135,164,169,171,174,182,187)
 	} else {
 		nicePch<-c(0:20)
 	}
 	if (nr > length(nicePch)){
   		nicePch <- rep(nicePch,ceiling(nr/length(nicePch)))
 	}
 	return(nicePch[PchToReFact])
 	##
 	newPch <- rep(NA, length(PchToReFact))
 	for (p in 1:nr){
   		a <- which(PchToReFact==unique(PchToReFact)[p])
   		newPch[a] <- nicePch[p]
 	}
 	return(newPch)
} # EOF

makePchGroup <- function(PchToReFact, extra = FALSE) {
	nr <- length(unique(PchToReFact))
 	if (extra) {
 		nicePch<-c(0:20,35,127,134,135,164,169,171,174,182,187)
 	} else {
 		nicePch<-c(0:20)
 	}
 	if (nr > length(nicePch)){
   		nicePch <- rep(nicePch,ceiling(nr/length(nicePch)))
 	}
 	return(nicePch[unique(PchToReFact)])
} # EOF
