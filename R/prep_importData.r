# read spectra ----------------------------------------------------------------------
readSpec_checkDefaults <- function(possibleFiletypes, md, filetype, naString) {
	if (all(filetype == "def")) {
		filetype <- .ap2$stn$imp_specFileType
	} else {
		if (!all(is.character(filetype)) | length(filetype) != 1) {
			stop("Please provide a character length one to the argument 'filetype'. Refer to the help for 'getFullData' for possible values.", call.=FALSE)
		}
	}
	if (grepl("custom@", filetype)) {
		custName <- strsplit(filetype, "custom@")[[1]][2]
		pathSH <- Sys.getenv("AQUAP2SH")
		if (!file.exists(paste(pathSH, custName, sep="/"))) {
 			stop(paste("The file \"", custName, "\" that contains the custom-function for importing of raw-spectra does not seem to exist in \n\"", pathSH, "\".\n", sep=""), call.=FALSE)
		} else {
			fc <- filetype
		}
	} else {
		fc <- NULL
	}
	possValues <- c(possibleFiletypes, fc) # so we are sure that we have a valid filename under fc 
	if (!any(possValues %in% filetype)) {
		stop("Please refer to the help for 'getFullData' for possible values for the argument 'filetype'. Have a good day.", call.=FALSE)
	}
	assign("filetype", filetype, pos=parent.frame(n=1))
	###
	if (!all(is.character(naString)) | length(naString) != 1) {
		stop("Please provide a character length one to the argument 'naString'.", call.=FALSE)
	}
	###
	if (class(md) == "aquap_md") {
		filename <- md$meta$expName
	} else {
		stop("Please provide a valid metadata object to the argument 'md'", call.=FALSE)
	}
	rawFolder <- .ap2$stn$fn_rawdata
	a <- list.files(rawFolder)
	if (!any(grepl(filename, a, fixed=TRUE))) {
		stop(paste("The file \"", filename, "\" does not seem to exist in \"", rawFolder, "\", sorry. \n", sep=""), call.=FALSE)
	}
	assign("filename", filename, pos=parent.frame(n=1))
} # EOF


#' @title Read Spectra
#' @description Reads in just the spectra from the provided rawdata file.
#' @details This function is mainly for providing a possibility to test custom 
#' written rawdata import functions. (see \code{\link{custom_import}})
#' @inheritParams getFullData
#' @return The spectral data in the format as described in 'Value' in 
#' \code{\link{custom_import}}
#' @seealso \code{\link{getFullData}}
#' @family Development Functions
#' @export
readSpectra <- function(md=getmd(), filetype="def", naString="NA") {
	autoUpS()
	possibleFiletypes <- c("vision_NSAS.da", "tabDelim.txt") # they get handed down to the checking function !  # XXVARXX
	filename <- NULL # will be changed in the checking
	readSpec_checkDefaults(possibleFiletypes, md, filetype, naString)
	rawFolder <- .ap2$stn$fn_rawdata
	folderFile <- paste(rawFolder, "/", filename, sep="")
	##
	if (filetype == "vision_NSAS.da") {
		a <- paste(folderFile, ".da", sep="")
		return(getNIRData_Vision_da(a))
	}
	##
	if (filetype == "tabDelim.txt") {
		a <- paste(folderFile, ".txt", sep="")
 		return(getNirData_plainText(a, naString))
	}
	## if nothing of the above happend, then we must have (checked!) the path to a valid custom .r file in "filetype" 
	custName <- strsplit(filetype, "custom@")[[1]][2]
	pathSH <- Sys.getenv("AQUAP2SH")
	pathToCustom <- paste(pathSH, custName, sep="/")
	e <- new.env()
	sys.source(pathToCustom, envir=e)
	a <- paste(folderFile, e$fileExtension, sep="")
	assign("spectraFilePath", a, pos=parent.frame(n=1))
	return(e$spectralImport(a))
} # EOF

gfd_check_imports <- function(specImp) {
#	outList <- list(sampleNr=sampleNr, conSNr=conSNr, timePoints=timePoints, ecrm=ecrm, repl=repl, group=group, temp=temp, relHum=relHum, C_cols=C_cols, Y_cols=Y_cols, timestamp=timestamp, info=info, NIR=NIR)
	namesOfListElements <- c("sampleNr", "conSNr", "timePoints", "ecrm", "repl", "group", "temp", "relHum", "C_cols", "Y_cols", "timestamp", "info", "NIR") ## XXXVARXXX
	if (!all(names(specImp) %in% namesOfListElements)) {
		stop("One or more of the elements in the list of your custom import function do have wrong names. \nPlease see the help for 'custom_import' for further information.", call.=FALSE)
	}
	namesOfInfoList <- c("nCharPrevWl") 	## XXXVARXXX
	if (!all(names(specImp$info) %in% namesOfInfoList)) {
		stop("One or more of the elements in the info-list generated by your custom import function do have wrong names. \nPlease see the help for 'custom_import' for further information.", call.=FALSE)		
	}
	a <- specImp$sampleNr
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'sampleNr' in the import function."),call.=FALSE)
		}
	}
	a <- specImp$conSNr
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'conSNr' in the import function."),call.=FALSE)
		}
	}
	a <- specImp$timePoints
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'timePoints' in the import function."),call.=FALSE)
		}
	}
	a <- specImp$ecrm
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'ecrm' in the import function."),call.=FALSE)
		}
	}
	a <- specImp$repl
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'repl' in the import function."),call.=FALSE)
		}
	}
	a <- specImp$group
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'group' in the import function."),call.=FALSE)
		}
	}
	a <- specImp$temp
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'temp' in the import function."),call.=FALSE)
		}
	}
	a <- specImp$relHum
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'relHum' in the import function."),call.=FALSE)
		}
	}
	a <- specImp$C_cols
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'C_cols' in the import function."),call.=FALSE)
		}
	}
	a <- specImp$Y_cols
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'Y_cols'" ), call.=FALSE)
		}
	}
	a <- specImp$timestamp
	if (!is.null(a)) {
		if (!is.data.frame(a)) {
			stop(paste("Please provide a data frame for the element 'timestamp' in the import function."),call.=FALSE)
		}
	}
	if (!is.null(specImp$NIR)) {
		if (!is.matrix(specImp$NIR)) {
			stop(paste("Please provide a matrix for the element 'NIR' in the import function."),call.=FALSE)
		}
	}
	a <- specImp$info$nCharPrevWl
	if (!all(is.numeric(a)) | length(a) !=1) {
		stop(paste("Please provide an integer length 1 for the element 'nCharPrevWl' in the import function."),call.=FALSE)
	}
	a <- specImp$info$nCharPrevWl
	if (!all(is.numeric(a)) | length(a) !=1) {
		stop("Please provide a length one numeric as the input for the element 'nCharPrevWl' in the import function", call.=FALSE)
	}
	ncpwl <- specImp$info$nCharPrevWl
	options(warn = -1)
	a <- as.numeric(substr(colnames(specImp$NIR), ncpwl+1, nchar(colnames(specImp$NIR))))
	options(warn = 0)
	if (any(is.na(a))) {
		stop("There is an error with the column names of the NIR spectra representing the wavelength. \nMaybe not all columns do have the same number of characters before the wavelength. \nPlease check in the import function if the provided number of characters before the wavelength is correct, and if the column names of the NIR data are correct as well.", call.=FALSE)
	}
} # EOF

gfd_makeNiceColumns <- function(specImp) {
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
	nr <- nrow(specImp$NIR)
	##
	if (!is.null(specImp$sampleNr)) {
		colnames(specImp$sampleNr) <- paste(yPref, sampleNrColn, sep="")
	} else {
		specImp$sampleNr <- data.frame(DELETE = rep(NA, nr))
	}
	if (!is.null(specImp$conSNr)) {
		colnames(specImp$conSNr) <- paste(yPref, conSNrColn, sep="")
	} else {
		specImp$conSNr <- data.frame(DELETE = rep(NA, nr))
	}	
	if (!is.null(specImp$timePoints)) {
		colnames(specImp$timePoints) <- paste(cPref, timePointsColn, sep="")
	}  else {
		specImp$timePoints <- data.frame(DELETE = rep(NA, nr))
	}	
	if (!is.null(specImp$ecrm)) {
		colnames(specImp$ecrm) <- paste(cPref, ecrmColn, sep="")
	}  else {
		specImp$ecrm <- data.frame(DELETE = rep(NA, nr))
	}	
	if (!is.null( specImp$repl)) {
		colnames(specImp$repl) <- paste(cPref, replColn, sep="")
	}  else {
		specImp$repl <- data.frame(DELETE = rep(NA, nr))
	}	
	if (!is.null(specImp$group)) {
		colnames(specImp$group) <- paste(cPref, groupColn, sep="")
	} else {
		specImp$group <- data.frame(DELETE = rep(NA, nr))
	}	
	if (!is.null(specImp$temp)) {
		colnames(specImp$temp) <- paste(yPref, tempColn, sep="")
	} else {
		specImp$temp <- data.frame(DELETE = rep(NA, nr))
	}	
	if (!is.null(specImp$relHum)) {
		colnames(specImp$relHum) <- paste(yPref, relHumColn, sep="")
	} else {
		specImp$relHum <- data.frame(DELETE = rep(NA, nr))
	}	
	if (!is.null(specImp$C_cols)) {
		lePref <- nchar(cPref)
		a <- colnames(specImp$C_cols)
		noPrefInd <- which(substr(a, 1, lePref) != cPref)
		if (length(noPrefInd) > 0) {
			colnames(specImp$C_cols)[noPrefInd] <- paste(cPref, a[noPrefInd], sep="")
		}
	} else {
		specImp$C_cols <- data.frame(DELETE = rep(NA, nr))
	}
	if (!is.null(specImp$Y_cols)) {
		lePref <- nchar(yPref)
		a <- colnames(specImp$Y_cols)
		noPrefInd <- which(substr(a, 1, lePref) != yPref)
		if (length(noPrefInd) > 0) {
			colnames(specImp$Y_cols)[noPrefInd] <- paste(yPref, a[noPrefInd], sep="")
		}
		specImp$Y_cols <- convertYColsToNumeric(specImp$Y_cols)
	} else {
		specImp$Y_cols <- data.frame(DELETE = rep(NA, nr))
	}
	if (!is.null(specImp$timestamp)) {
		if (.ap2$stn$imp_makeTimeDistanceColumn) {
			startDate <- as.POSIXct(.ap2$stn$imp_startDate)
			startDateNr <- as.double(startDate)
			a <- unclass(specImp$timestamp[,1])
			MinuteTimStamp <- as.numeric(round((a - startDateNr)/60, 2))
			chrons <- data.frame(absTime=MinuteTimStamp, chron=1:length(MinuteTimStamp))
			timestamp <- specImp$timestamp
			specImp$timestamp <- cbind(specImp$timestamp, chrons)
			colnames(specImp$timestamp) <- c("Timestamp", "absTime", "chron")
		} else {
			colnames(specImp$timestamp) <- "Timestamp"		
		}
	} else {
		specImp$timestamp <- data.frame(DELETE = rep(NA, nr))
	}
	return(specImp)
} # EOF

gfd_checkNrOfRows <- function(header, headerFilePath, nrowsNIR, spectraFilePath, multiplyRows, nrConScans) {
	if (!is.null(header)) {
		if (nrow(header) != nrowsNIR) {
			if (multiplyRows) {
				to <- paste("after the multiplication of every row by ", nrConScans, " consecutive scans", sep="")
			} else {
				to <- "(multiplication of rows was *not* performed)"
			}
			stop(paste("The header that was constructed from the file \n\"", headerFilePath, "\"\n consists of ", nrow(header), " rows ", to, ", while the imported spectra from file \n\"", spectraFilePath, "\"\n consist of ", nrowsNIR, " rows. \nPlease make sure that all data to be imported have the same number of rows.", sep=""), call.=FALSE)
		}
	}
} # EOF

gfd_getExpNameNoSplit <- function(metadata, nRows) {
	cPref <- .ap2$stn$p_ClassVarPref
	makeExpNameColumn <- .ap2$stn$imp_makeExpNameColumn
	makeNoSplitColumn <- .ap2$stn$imp_makeNoSplitColumn
	##
	if (makeExpNameColumn) {
		expName <- data.frame(rep(metadata$meta$expName, nRows))
		colnames(expName) <- paste(cPref, .ap2$stn$p_expNameCol, sep="")
	} else {
		expName <- data.frame(DELETE = rep(NA, nRows))
	}
	assign("expName", expName, pos=parent.frame(n=1))
	##
	if (makeNoSplitColumn) {
		noSplit <- data.frame(rep(.ap2$stn$p_commonNoSplit, nRows))
		colnames(noSplit) <- paste(cPref, .ap2$stn$p_commonNoSplitCol, sep="")
	} else {
		noSplit <- data.frame(DELETE = rep(NA, nRows))	
	}
	assign("noSplit", noSplit, pos=parent.frame(n=1))
} # EOF

gfd_checkForDoubleColumns <- function(header, spectraFilePath, headerFilePath, slType) {
	collect  <-  NULL
	patterns <- c(".1", ".2", ".3", ".4", ".5", ".6", ".7", ".8", ".9", ".10", ".11", ".12")
	a <- colnames(header)
	for (k in 1: length(patterns)) {	
		inds <- grep(patterns[k], a)
		if (length(inds) > 0) {
			collect <- c(collect, inds)
		}
	}  # end for k
	if (!is.null(collect)) {
		if (is.null(slType)) {
			files <- paste("\"", spectraFilePath, "\"", sep="")		
		} else {
 			files <- paste("\"", headerFilePath, "\" and ", "\"", spectraFilePath, "\".", sep="")
		}
		cols <- paste(a[collect], collapse=", ")
		msg <- paste("Some columns seem to appear twice: \n", cols,"\nPlease check the files used for importing data, that is \n", files, sep="")
		stop(msg, call.=FALSE)
	}
} # EOF

gfd_importData <- function() {


} # EOF

gfd_checkLoadSaveLogic <- function(ttl, stf) {
	if (!is.logical(ttl) | !is.logical(stf)) {
		stop("Please provide 'TRUE' or 'FALSE' to the arguments 'ttl' / 'stf' ", call.=FALSE)
	}
} # EOF

gfd_checkMetadata <- function(md) {
	if (class(md) != "aquap_md") {
		stop("Please provide a valid metadata object of class 'aquap_md' to the argument 'md'", call.=FALSE)
	}
} # EOF

# get full data ---------------------------------------------------------------
#' @rdname getFullData
#' @export
getFullData <- function(md=getmd(), filetype="def", naString="NA", slType="def", multiplyRows="def", ttl=TRUE, stf=TRUE) {
	autoUpS()
	gfd_checkLoadSaveLogic(ttl, stf)
	gfd_checkMetadata(md)
	dataset <- NULL
	if (ttl) {
		dataset <- loadAQdata(md, verbose=FALSE)
	}
	if(!is.null(dataset)) { # so the path existed and it could be loaded
		if(!.ap2$stn$allSilent) {cat(paste("Dataset \"", md$meta$expName, "\" was loaded.\n", sep="")) }
		return(invisible(dataset)) # returns the dataset and we exit here
	}
  # import starts 
  if(!.ap2$stn$allSilent) {cat("Importing data...\n")}	
	headerFilePath <- NULL # gets assigned in readHeader()
	header <- readHeader(md, slType, multiplyRows) ## re-assigns 'slType' and 'multiplyRows' also here -- in parent 2 level frame 
													## if slType is NULL, header will be returned as NULL as well
	spectraFilePath <- NULL # gets assigned in readSpectra()
	si <-  readSpectra(md, filetype, naString) ### !!!!!!!!! here the import !!!!!!!!!
	gfd_check_imports(si) # makes sure eveything is NULL or data.frame / matrix (NIR)
	si <- gfd_makeNiceColumns(si) # makes all column names, transforms Y-variables to numeric
	nr <- nrow(si$NIR)
	gfd_checkNrOfRows(header, headerFilePath, nr, spectraFilePath, multiplyRows, nrConScans=md$postProc$nrConScans)  # makes sure spectra and sample list have same number of rows
	if (is.null(header)) {
		header <- data.frame(DELETE=rep(NA, nr))
	}
	expName <- noSplit <- NULL # gets assigned below in gfd_getExpNameNoSplit()
	gfd_getExpNameNoSplit(metadata=md, nRows=nr)
	headerFusion <- cbind(expName, noSplit, header, si$sampleNr, si$conSNr, si$timePoints, si$ecrm, si$repl, si$group, si$C_cols, si$Y_cols,  si$temp, si$relHum, si$timestamp)
	headerFusion <- headerFusion[, -(which(colnames(headerFusion) == "DELETE"))] 
	check_conScanColumn(headerFusion, headerFilePath, spectraFilePath, slType) 
	# ? check for existence of sample number column as well ?
	gfd_checkForDoubleColumns(headerFusion, spectraFilePath, headerFilePath, slType)	
	if (.ap2$stn$imp_autoCopyYvarsAsClass) {  # if TRUE, copy all columns containing a Y-variable as class variable
		headerFusion <- copyYColsAsClass(headerFusion)
	}
	headerFusion <- remakeTRHClasses_sys(headerFusion)
	colRep <- extractClassesForColRep(headerFusion)		## the color representation of the factors
	NIR <- si$NIR
	rownames(NIR) <- make.unique(rownames(NIR)) # just to be sure
	rownames(headerFusion) <- rownames(colRep) <- rownames(NIR)
#	fd <- data.frame(I(header), I(colRep), I(NIR))
	fullData <- new("aquap_data")
	fullData@header <- headerFusion
	fullData@colRep <- colRep
	fullData@NIR <- NIR
	fullData@ncpwl <- si$info$nCharPrevWl
	if (stf) {
		saveAQdata(fullData, md, verbose=TRUE)
	} else {
		if(!.ap2$stn$allSilent) {cat("Done. (not saved) \n")}	
	}
	return(invisible(fullData))
} # EOF

#' @rdname getFullData
#' @export
gfd <- function(md=getmd(), filetype="def", naString="NA", slType="def", multiplyRows="def", ttl=TRUE, stf=TRUE) {
	return(getFullData(md, filetype, naString, slType, multiplyRows, ttl, stf))
} # EOF


#' @title Save and load aquap2 datasets
#' @description Save and load the standard aquap2 dataset (class "aquap_data") 
#' to / from the 'R-data' folder.
#' @details  From the provided metadata the experiment name is extracted.
#' \itemize{
#'  \item saveAQdata The dataset is saved under the same name as the experiment name.
#'  \item laodAQdata The file having the same name as the experiment name is being 
#'  loaded.
#' } 
#' @inheritParams getFullData
#' @param dataset An object of class 'aquap_data'
#' @param verbose Logical, if messages should be displayed.
#' @return loadData 
#' @family Helper Functions
#' @seealso \code{\link{getFullData}}
#' @examples
#' \dontrun{
#' saveAQdata(dataset)
#' loadAQdata()
#' }
#' @export
saveAQdata <- function(dataset, md=getmd(), verbose=TRUE) {
	autoUpS()
  	if (class(dataset) != "aquap_data") {
    	stop("Please provide an object of class 'aquap_data' to the argument 'dataset'", call.=FALSE)
  	}
  	expName <- md$meta$expName
	path <- paste(.ap2$stn$fn_rdata, expName, sep="/")
	save(dataset, file=path)
	if (verbose & !.ap2$stn$allSilent) {
		cat(paste("Dataset saved under \"", path, "\".\n", sep=""))
	}
} # EOF

#' @rdname saveAQdata
#' @export
loadAQdata <- function(md=getmd(), verbose=TRUE) {
	autoUpS()
  	expName <- md$meta$expName
	path <- paste(.ap2$stn$fn_rdata, expName, sep="/")
	if (file.exists(path)){
		a <- load(path)
		if (verbose & !.ap2$stn$allSilent) {
			cat(paste("Dataset \"", path, "\" loaded.", sep=""))
		}
		invisible(get("dataset"))	
	} else {
		if (verbose) {
			message(paste("Dataset \"", path, "\" does not seem to exist, sorry.", sep=""))
		}
		return(NULL)
	}	
} # EOF

# refine header -------------------------------------------------------------
transformNrsIntoColorCharacters <- function(numbers) {
	whatColors = c("black", "red", "green", "blue", "cyan", "magenta", "yellow2", "gray")
	colRamp <- colorRampPalette(whatColors)
	colorChar <- colRamp(length(unique(numbers))) 		## XXX unique needed here?
	return(as.character(colorChar[numbers]))
} # EOF

generateHeatMapColorCoding <- function(numbers) {
	whatColors <- .ap2$stn$col_RampForTRH
	colRamp <- colorRampPalette(whatColors)
	colorChar <- colRamp(length(unique(numbers)))
	out <- as.character(colorChar[numbers])
} # EOF

extractClassesForColRep <- function(header) { ## does not need "NIR" present in the data frame
	tempCol <- .ap2$stn$p_tempCol ## depends on "grepl" or not
	RHCol <- .ap2$stn$p_RHCol
	out <- data.frame(matrix(NA, nrow=nrow(header)))
	for (i in 1: ncol(header)) {
		if (is.factor(header[,i])) {
			a <- data.frame( as.numeric(unclass(header[,i])))
			levelsA <- unique(a[,1])
			cn <- colnames(header[i])
			if (grepl(tempCol, cn) | grepl(RHCol, cn)) {
				a[1] <- generateHeatMapColorCoding(a[,1])
			} else {
				if (length(levelsA) > 8) { ## we only have 8 integer representations for colors
					a[1] <- transformNrsIntoColorCharacters(a[,1])
				} # end if
			}
			names(a) <- colnames(header[i])
			out <- data.frame(out,a)
		} # end if 
	} # end for i
	return(out[-1])		# cut off the first column containing only the NAs
} # EOF 

copyYColsAsClass <- function(sampleList) {
	yPref <- .ap2$stn$p_yVarPref
	cPref <- .ap2$stn$p_ClassVarPref
	ind  <- grep(yPref, colnames(sampleList))
#	print(ind); wait()
#	print(colnames(sampleList[ind])); wait()
	add <- data.frame(matrix(NA,nrow(sampleList)))
	for (i in 1: length(ind)) {
		colName <- names(sampleList[ind[i]])
		newColName <- sub(yPref, cPref, colName)
		numCol <- sampleList[, ind[i] ]
		factorCol <- factor(as.character(numCol), exclude=NA) 
		newDF <- data.frame(factorCol)
		names(newDF)[1] <- newColName
		add <- data.frame(add, newDF )
	}
	add <- add[-1]
	return(data.frame(sampleList, add))
} # EOF

remakeTRHClasses_sys <- function(headerOnly, TDiv=.ap2$stn$imp_TClassesDiv, TRound=.ap2$stn$imp_TRounding, RHDiv=.ap2$stn$imp_RHClassesDiv, RHRound= .ap2$stn$imp_RHRounding) {
	options(warn=-1)
	cPref <- .ap2$stn$p_ClassVarPref
	Tpat <- paste(cPref, .ap2$stn$p_tempCol, sep="") 						# read in the prefix for class and temperature from settings
	RHpat <- paste(cPref, .ap2$stn$p_RHCol, sep="")							# read in the prefix for class and rel. humidity from settings
	TInd <- grep(.ap2$stn$p_tempCol, colnames(headerOnly), fixed=TRUE)		# find column-index that has the temperatur - the source
	TClInd  <- grep(Tpat, colnames(headerOnly), fixed=TRUE)					# find column-index that the temperatur already as class - the target
	RHInd <- grep(.ap2$stn$p_RHCol, colnames(headerOnly), fixed=TRUE)		# find column-index that has the rel. hum.
	RHClInd  <- grep(RHpat, colnames(headerOnly), fixed=TRUE)				# find column-index that the re.hum. already as class - the target
	numsTemp <- headerOnly[, TInd[1] ]										# extract the numbers
	numsRH <- headerOnly[, RHInd[1] ]										# extract the numbers
	headerOnly[TClInd] <- factor(round((numsTemp/TDiv),TRound)*TDiv)		# insert the new classes
	headerOnly[RHClInd] <- factor(round((numsRH/RHDiv),RHRound)*RHDiv)		# insert the new classes
	options(warn=0)
	return(headerOnly)
} # EOF

# read header ----------------------------------------------------------------
convertYColsToNumeric <- function(sampleList) {
	options(warn=-1)
	pref <- .ap2$stn$p_yVarPref
	ind  <- grep(pref, colnames(sampleList))
	for (i in 1: length(ind)) {
		sampleList[ind[i]] <- as.numeric( as.character(sampleList[, ind[i]]) )
	}
	options(warn=0)
	return(sampleList)
} # EOF

### x-fold every line (Nr. Cons. Measurements), and add a numbering for each of the consecutive scans
multiplySampleListRows <- function(sampleList, nrScans) {
	multiList <- NULL
#	sampleList <- as.data.frame(sampleList)
	for (i in 1:nrScans) {
		multiList <- rbind(multiList, sampleList)
	} # end i loop
	second <- matrix(rep(1:nrScans, each=nrow(sampleList) ))
	first <- matrix(rep(1:nrow(sampleList), nrScans) )
	a <- data.frame(multiList, second=second, first=first)
	a <- as.data.frame(a[order(first, second), ][,1:(ncol(a)-2)]) # order, then cut away the last two columns

	ConSNr <- rep(1:(nrScans),nrow(sampleList)) # generate a vector numbering all the consecutive scans
	if (ncol(a) > 1) {
		a <- data.frame(a[1], ConSNr=ConSNr, a[-1]) # insert into data frame
	} else {
		a <- data.frame(a[1], ConSNr=ConSNr) # insert into data frame		
	}
	ColNames <- colnames(a)
	ColNames[2] <- paste(.ap2$stn$p_yVarPref, .ap2$stn$p_conSNrCol, sep="")
	colnames(a) <- ColNames
	rownames(a) <- seq(1:nrow(a)) # correct all the rownames
	return(a)
} # EOF

readHeader_checkDefaults <- function(slType, possibleValues, md, multiplyRows) {
	if (all(slType == "def") & !is.null(slType)) {
		slType <- .ap2$stn$imp_sampleListType
	}
	if (!is.null(slType)) {
		if (!all(is.character(slType)) | length(slType) != 1) {
			stop("Please provide a character length one or NULL to the argument 'slType'.", call.=FALSE)
		}
	}
	if (!any(possibleValues %in% slType) & !is.null(slType)) {
		stop("Please refer to the help for 'getFullData' for the possible values for the argument 'slType'", call.=FALSE)
	}
	assign("slType", slType, pos=parent.frame(n=1))
	assign("slType", slType, pos=parent.frame(n=2)) # that is needed to always have the correct value for slType in the getFullData function
	###
	if (class(md) == "aquap_md") {
		filename <- md$meta$expName
	} else {
		stop("Please provide a valid metadata object of class 'aquap_md' to the argument 'md'", call.=FALSE)
	}
	assign("filename", filename, pos=parent.frame(n=1))
	###
	if (all(multiplyRows == "def")) {
		multiplyRows <- .ap2$stn$imp_multiplyRows
	} else {
		if (!all(is.logical(multiplyRows)) | length(multiplyRows) != 1) {
			stop("Please provide either 'TRUE' or 'FALSE' to the argument 'multiplyRows'.", call.=FALSE)
		}
	}
	assign("multiplyRows", multiplyRows, pos=parent.frame(n=1))
	assign("multiplyRows", multiplyRows, pos=parent.frame(n=2))  # that is needed to always have the correct value for multiplyRows in the getFullData function
} # EOF

check_sl_existence <- function(filename, ext) {
	slInFolder <- paste(.ap2$stn$fn_sampleLists, "/", .ap2$stn$f_sampleListIn, sep="")
	fn <- paste(filename, ext, sep="")
	a <- paste(slInFolder, "/", fn, sep="")
	if (!file.exists(a)) {
		stop(paste("The file \"", fn, "\" does not seem to exist in \"", slInFolder, "\".", sep=""), call.=FALSE)
	}	
} # EOF

check_conScanColumn <- function(header, headerFilePath, spectraFilePath, slType) {
	a <- paste(.ap2$stn$p_yVarPref, .ap2$stn$p_conSNrCol, sep="")
	if (!any(a %in% colnames(header))) {
		if (is.null(slType)) {
			from <- paste(" in the file \n\"", spectraFilePath, "\" containing the spectral data.", sep="")
			where <- paste(" to the file containing the spectral data and modify the custom import function accordingly.\n")
			maybe <- ""
		} else {
			from <- paste(", neither in your sample-list file \n\"", headerFilePath, "\", nor in file \n\"", spectraFilePath, "\" containing the spectral data.", sep="")
			where <- paste(" either to the sample list or to the file containing the spectral data. In the latter case please modify the custom import function accordingly.\n")
 			maybe <- "(You probably encounter this error because you did choose to *not* multiply the rows of the sample list by the nr. of consecutive scans.)\n"
		}
		msg <- paste("You do not have a column for the nr of the consecutive scan", from, " \nPlease, add a column called \"", a, "\"", where, maybe, "\nSee the help for 'custom_import' for further information.", sep="")
		stop(msg, call.=FALSE)
	}	
} # EOF

check_conScanColumn_2 <- function(header, filename, ext) {
	a <- paste(.ap2$stn$p_yVarPref, .ap2$stn$p_conSNrCol, sep="")
	if (!any(a %in% colnames(header))) {
		stop(paste("You do not have a column for the nr of the consecutive scan in your sample list called \"", filename, ext, "\". \nPlease, add a column called \"", a, "\" to the file as the second column and provide the right values in this column. \n(You probably encounter this error because you did choose to *not* multiply the rows of the sample list by the nr. of consecutive scans.)\nPlease refer to the help for 'getFullData' for further information.", sep=""), call.=FALSE)
	}
	ind <- grep(a, colnames(header), fixed=TRUE)
	if (ind != 2) {
		stop(paste("Your 'custom-column' for the number of the consecutive scan should, please, be the second column. \nPlease modify the file \"", filename, ext, "\" accordingly.", sep=""), call.=FALSE)
	}
} # EOF

#' @title Read Header
#' @description This functions reads in the sample-list file and prepares the 
#' header to be fused with the spectral data. 
#' Usually you do not need to call this function.
#' @details  From the metadata, provided in the first argument, the experiment 
#' name is extracted; the sample list (what is used to create the header) must be in the 
#' sampleLists/sl_in folder and must be named with the experiment name, followed 
#' by a "-in" and then the file extension.
#' @inheritParams getFullData
#' @seealso \code{\link{getFullData}}
#' @examples
#' \dontrun{
#'  header <- readHeader()
#' }
#' @family Development Functions
#' @export
readHeader <- function(md=getmd(), slType="def", multiplyRows="def") {
	autoUpS()
	poss_sl_types <- c("csv", "txt", "xls") 			### XXXVARXXX
	filename <- NULL # will be changed in the checking
	readHeader_checkDefaults(slType, poss_sl_types, md, multiplyRows)
	slInFolder <- paste(.ap2$stn$fn_sampleLists, "/", .ap2$stn$f_sampleListIn, "/", sep="")
	if (is.null(slType)) {
		return(NULL)
	}
	if (slType == "csv") {
		ext <- "-in.csv"
		check_sl_existence(filename, ext)
		rawHead <- read.csv(paste(slInFolder, filename, ext, sep=""))
	}
	if (slType == "txt") {
		ext <- "-in.txt"
		check_sl_existence(filename, ext)
		rawHead <- read.table(paste(slInFolder, filename, ext, sep=""), header=TRUE)
	}
	if (slType == "xls") {
		ext <- "-in.xlsx"
		check_sl_existence(filename, ext)
		rawHead <- xlsx::read.xlsx(paste(slInFolder, filename, ext, sep=""), sheetIndex=1, header = TRUE)
	}
	assign("headerFilePath", paste(slInFolder, filename, ext, sep=""), pos=parent.frame(n=1))
	###
	rawHead <- convertYColsToNumeric(rawHead)
	nrScans <- md$postProc$nrConScans
	if (multiplyRows) {
		header <- multiplySampleListRows(rawHead, nrScans)
	} else {
		header <- rawHead
		# check_conScanColumn_2(header, filename, ext)
	}
	return(header)
} # EOF


## maybe add here the user-function for re-making the T and RH classes
# XXX

## import & align TRH from a / any logfile	
# make tutorial; make data-package

## note: make @numRep in Aquacalc to take numerics OR character, because if we have more than 8 elements...  :-)
