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
 			stop(paste("It appears that the file \"", custName, "\" that contains the custom-function for importing of raw-spectra does not seem to exist in \n\"", pathSH, "\".\n", sep=""), call.=FALSE)
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
#' @family Development
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
	return(e$spectralImport(a))
} # EOF

# get full data ---------------------------------------------------------------
#' @title Get / Import Spectral Data
#' @description Loads an R-object containing previously imported spectral data, 
#'  or imports spectral data from a file in the rawdata-folder and fuses 
#' these data together with the class-header provided in the sampleLists/sl_in 
#' folder.
#' @details From the metadata, provided in the first argument, the experiment 
#' name is extracted, and the spectral file having the same name as the experiment 
#' name (plus its specific ending) is imported from the rawdata-folder. 
#' The sample list (what is used to create the header) must be in the 
#' sampleLists/sl_in folder and must be named with the experiment name, followed 
#' by a "-in" and then the file extension.
#' @section Note: This strict regime with the filenames seems maybe at first at 
#' bit complicated, but it proved to be good practise to ensure and enforce a 
#' strict and conscious handling of the files.
#' @param md List. The object with the metadat of the experiment. 
#' The default is to get the metadata file via  \code{\link{getmd}}.
#' @param filetype Character. The type of the spectral raw data file. 
#' Possile values are:
#' \itemize{
#' \item "def": Gets the default value from the setings.r file. 
#'      (variable 'imp_specFileType')
#' \item "vision_NSAS.da": Import from the .da file generated by the Vision-software
#' from a Foss-XDS spectroscope.
#' \item "tabDelim.txt": Import any tab delimited text file that contains only 
#' the NIR spectra and *no* additional columns like e.g. time, temperature etc.
#' \item "custom@@yourFile.r": You can provide your own import-function for 
#' importing spectra, with "yourFile.r" being the .r-file located in the path 
#' specified in the .Renviron file. Please refer to \code{\link{custom_import}} 
#' for further information.
#' }
#' @param naString Character. What to use as 'NA'. Applies only when 'filetype' 
#' is 'tabDelim.txt'.
#' @param slType Character. The type of sample-list file in the sampleLists/
#' sl_in folder. Possible values are:
#' \itemize{
#'    \item "def" Gets the default value from the settings.r file.
#'          (variable 'imp_sampleListType')
#'    \item "csv" a comma separated text file ending in '.csv'
#'    \item "txt" a tab delimited text file ending in '.txt'
#'    \item "xls" an Excel file ending in '.xlsx'
#' }
#' @param multiplyRows Character or Logical. If all the rows in the sample list 
#' should be multiplied by the number of consecutive scans as specified in the 
#' metadata of the experiment. If 'FALSE' (what would be the case if you, during 
#' your measurements, had to divert from the planned number of consecutive scans
#' or had to make other changes so that the number of consecutive scans is not 
#' the same for every sample) you have manually insert the column (default name 
#' would be 'C_ConSNr' and provide the values for every row.
#' 
#' @param stf Logical, 'save to file'. If the final dataset should be saved to 
#' the 'R-data' folder. Defaults to 'TRUE'.
#' @seealso \code{\link{readSpectra}}, \code{\link{readHeader}}
#' @return XXX
#' @examples
#' \dontrun{
#'  md <- getmd()
#'  fd <- getFullData(md)
#'  fd <- getFullData() # the same as above
#'  fd <- getFullData(filetype="custom@@myFunc.r", slType="xls")
#'  # This would use a custom function to read in the raw spectra, and read in 
#'  # the header file from an Excel file.
#' }
#' @export
getFullData <- function(md=getmd(), filetype="def", naString="NA", slType="def", multiplyRows="def",  stf=TRUE) {
	autoUpS()
	spectraImport <-  readSpectra(md, filetype, naString)
		info <- spectraImport$info  # 	info <- list(nCharPrevWl=nCharPrevWl)
		addCols <- spectraImport$addCols
		NIR <- spectraImport$NIR
	header <- readHeader(md, slType, multiplyRows)
	cns <- colnames(addCols)
	##
	indT <- which(cns == "Timestamp")
	if (length(ind) != 0) {
		timestamp <- addCols[ind]
	} else {
		timestamp <- data.frame(Timestamp = rep(NA, nrow(NIR)))
	}
	##
	if (ncol(addCols) > 1) {
		addColsRest <- as.data.frame(addCols[, -indT])
	} else {
		addColsRest <- NULL
	}
	headerFusion <- cbind(header, addColsRest, timestamp)
	if (.ap2$stn$imp_autoCopyYvarsAsClass) {  # if TRUE, copy all columns containing a Y-variable as class variable
		header <- copyYColsAsClass(headerFusion)
	}
	headerFusion <- remakeTRHClasses_sys(headerFusion)
	numRep <- extractClassesForNumRep(headerFusion)		## the numerical representation of the factors
	chrons <- NULL
	fullData <- data.frame(headerFusion, timeStamp, chrons, I(numRep), I(NIR))		### FUSION HERE 
	return(fullData)
	## to do: correct the globals in the color-functions, add possibility to replace temp and relhum by columns in the spectral data?, test the placement of the additional columns, write the documentation in the make custom doc file
} # EOF

# refine header -------------------------------------------------------------
transformNrsIntoColorCharacters <- function(numbers) {
	whatColors = c("black", "red", "green", "blue", "cyan", "magenta", "yellow2", "gray")
	colRamp <- colorRampPalette(whatColors)
	colorChar <- colRamp(length(unique(numbers))) 		## XXX unique needed here?
	return(as.character(colorChar[numbers]))
} # EOF

generateHeatMapColorCoding <- function(numbers) {
	whatColors <- get("stngs")$colorRampForTRH
	colRamp <- colorRampPalette(whatColors)
	colorChar <- colRamp(length(unique(numbers)))
	out <- as.character(colorChar[numbers])
} # EOF

extractClassesForNumRep <- function(header) { ## does not need "NIR" present in the data frame
	tempCol <- get("stngs")$tempCol ## depends on "grepl" or not
	RHCol <- get("stngs")$RHCol
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
	out <- data.frame(sampleList, add)
	return(out)
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
	for (i in 1:nrScans) {
		multiList <- rbind(multiList, sampleList)
	} # end i loop
	second <- matrix(rep(1:nrScans, each=nrow(sampleList) ))
	first <- matrix(rep(1:nrow(sampleList), nrScans) )
	a <- data.frame(multiList, second=second, first=first)
	a <- a[order(first, second), ][,1:(ncol(a)-2)] # order, then cut away the last two columns
	ConSNr <- rep(1:(nrScans),nrow(sampleList)) # generate a vector numbering all the consecutive scans
	a <- data.frame(a[1], ConSNr=ConSNr, a[-1]) # insert into data frame
	ColNames <- colnames(a)
	ColNames[2] <- paste(.ap2$stn$p_yVarPref, .ap2$stn$p_conSNrCol, sep="")
	colnames(a) <- ColNames
	rownames(a) <- seq(1:nrow(a)) # correct all the rownames
	return(a)
} # EOF

readHeader_checkDefaults <- function(slType, possibleValues, md, multiplyRows) {
	if (all(slType == "def")) {
		slType <- .ap2$stn$imp_sampleListType
	}
	if (!all(is.character(slType) | length(slType) != 1)) {
		stop("Please provide a character length one to the argument 'slType'.", call.=FALSE)
	}
	if (!any(possibleValues %in% slType)) {
		stop("Please refer to the help for 'getFullData' for the possible values for the argument 'slType'", call.=FALSE)
	}
	assign("slType", slType, pos=parent.frame(n=1))
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
} # EOF

check_sl_existence <- function(filename, ext) {
	slInFolder <- paste(.ap2$stn$fn_sampleLists, "/", .ap2$stn$f_sampleListIn, sep="")
	fn <- paste(filename, ext, sep="")
	a <- paste(slInFolder, "/", fn, sep="")
	if (!file.exists(a)) {
		stop(paste("The file \"", fn, "\" does not seem to exist in \"", slInFolder, "\".", sep=""), call.=FALSE)
	}	
	
} # EOF

check_conScanColumn <- function(header, filename, ext) {
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
#' @family Development
#' @export
readHeader <- function(md=getmd(), slType="def", multiplyRows="def") {
	autoUpS()
	poss_sl_types <- c("csv", "txt", "xls") 			### XXXVARXXX
	filename <- NULL # will be changed in the checking
	readHeader_checkDefaults(slType, poss_sl_types, md, multiplyRows)
	slInFolder <- paste(.ap2$stn$fn_sampleLists, "/", .ap2$stn$f_sampleListIn, "/", sep="")
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
	###
	rawHead <- convertYColsToNumeric(rawHead)
	nrScans <- md$postProc$nrConScans
	if (multiplyRows) {
		header <- multiplySampleListRows(rawHead, nrScans)
	} else {
		header <- rawHead
		check_conScanColumn(header, filename, ext)
	}
	return(header)
} # EOF


## maybe add here the user-function for re-making the T and RH classes
# XXX


## next: add experiment name to the dataset, make import of spectra clean
