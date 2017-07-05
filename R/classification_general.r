# core classFunc definitions -----------
coreClassCalc_LDA <- function(dfData, apCl=NULL) {
	return(MASS::lda(grouping ~ NIR, data=dfData))
} # EOF

coreClassCalc_QDA <- function(dfData, apCl=NULL) {
	return(MASS::qda(grouping ~ NIR, data=dfData))
} # EOF

coreClassCalc_FDA <- function(dfData, apCl=NULL) {
	return(mda::fda(grouping ~ NIR, data=dfData))
} # EOF

coreClassCalc_mclustDA <- function(dfData, apCl=NULL) { # ! no formula interface here !
	return(mclust::MclustDA(dfData$NIR, dfData$grouping)) 
} # EOF

coreClassCalc_randomForest <- function(dfData, apCl=NULL) {
	return(randomForest::randomForest(grouping ~ NIR, data=dfData))
} # EOF

coreClassCalc_SVM <- function(dfData, apCl=NULL) {
	return(e1071::svm(grouping ~ NIR, data=dfData))
} # EOF

coreClassCalc_nnet <- function(dfData, apCl=NULL) {
	return(nnet::nnet(grouping ~ NIR, data=dfData))
} # EOF

getClassifierFunction <- function(char) {
	# pv: pv_classificationFuncs_XDA <- c("lda", "qda", "fda", "mclustda");   pv_allClassificationFuncs: + "randForest", "svm", "nnet"
	pvClass <- pv_allClassificationFuncs
	if (char == pvClass[1]) { # lda
		return(coreClassCalc_LDA)
	}
	if (char == pvClass[2]) { # qda
		return(coreClassCalc_QDA)
	}
	if (char == pvClass[3]) { # fda
		return(coreClassCalc_FDA)
	}
	if (char == pvClass[4]) { # mclustda
		return(coreClassCalc_mclustDA)
	}
	if (char == pvClass[5]) { # randForest
		return(coreClassCalc_randomForest)
	}
	if (char == pvClass[6]) { # svm
		return(coreClassCalc_SVM)
	}
	if (char == pvClass[7]) { # nnet
		return(coreClassCalc_nnet)
	}
} # EOF



# segment lists and dataset splitting ---------
createSegmentListForClassification <- function(header, nrSegs=10, classOn, stnLoc) { # looks in each group individually
	yPref <- stnLoc$p_yVarPref
	snCol <- stnLoc$p_sampleNrCol
	csnCol <- stnLoc$p_conSNrCol
	nrSegsSwitch <- 2
	## first see how many consecutive scans there are within each sample number (some (outlier) could have been removed)	
	snName <- paste0(yPref, snCol)
	snInd <- which(colnames(header) == snName)
	conSnInd <- which(colnames(header) == paste0(yPref, csnCol))
	classOnInd <- which(colnames(header) == classOn)
	headerDim <- header[,c(snInd, conSnInd, classOnInd)]
#	res <- plyr::ddply(headerDim, snName, nrow) 		## data frame with two columns, has the number of rows in in the second column
	res <- plyr::ddply(headerDim, c(snName, classOn), nrow) 		## data frame with three columns, has the number of rows in in the third column
	segList <- levChars <-  NULL
	currInd <- 1
	for (i in 1: nrow(res)) {
		indices <- currInd:( (currInd-1) + res[i,3] )
		currInd <- max(indices)+1
		segList <- c(segList, list(indices))  ## gives segList with all the same sample numbers (different cons. scans from the same sample number) in the same list element
		levChars <- c(levChars, as.character(res[i,2])) # the current character with one of the levels of classOn)
	} # end for i
#	if (length(segList) <= nrSegsSwitch) { # ???
#		return(nrow(header))
#	}
	# now group the segList according to the level character, as we want to make sure that we have equal samples from every group
	siLevs <- unique(levChars)
	groupedSegList <- list(); length(groupedSegList) <- length(siLevs)
	for (i in 1: length(siLevs)) {
		ind <- which(levChars == siLevs[i])
		groupedSegList[[i]] <- segList[ind]
	} # end for i
	## randomize
	minLeng <- min(unlist(lapply(groupedSegList, length)))
	if (nrSegs > minLeng) {
		nrSegs <- minLeng
	}
	groupedList <- list(); length(groupedList) <- length(groupedSegList)
	for (i in 1: length(groupedSegList)) {
		le <- length(groupedSegList[[i]])
		pool <- 1: le
		nrFull <- floor(le / nrSegs)
		indList <- NULL
		for (k in 1: nrSegs) {
			res <- sample(pool, nrFull)
			pool <- pool[-(which(pool %in% res))]
			indList <- c(indList, list(res))
		} # end for k
		if (length(pool) > 0) {
			for (k in 1: length(pool)) {
				indList[[k]] <- c(indList[[k]], pool[k]) # add the rest of the values to the seg list
			}
		}
		## map back to the segment list
#		out <- lapply(indList, function(x) unlist(segList[x]))
		out <- lapply(indList, function(x) unlist(groupedSegList[[i]][x]))
		groupedList[[i]] <- out
	} # end for i
	# now get together the indices from the single groups
	outList <- vector("list", nrSegs)
	for (i in 1: length(outList)) {
		for (k in 1: length(groupedList)) {
			outList[[i]] <- c(outList[[i]], groupedList[[k]][[i]])
		} 
	} # end for i
	outList <- lapply(outList, sort)
	aa <- unlist(lapply(outList, length))
	outList <- outList[order(aa)] # puts the (possibly) shortest segment on position #1
	return(outList) 		
} # EOF

makeOuterSplitList <- function(dataset, percTest, classOn, stnLoc=.ap2$stn) {
	if (percTest <= 0) {
		percTest <- 100 # so the below division still works and is resulting in 1
	}
	nrOuterLoops <- round(100/percTest, 0)
	splitList <- createSegmentListForClassification(dataset$header, nrSegs=nrOuterLoops, classOn, stnLoc)
	return(splitList)
} # EOF

makeOuterSplitDatasets <- function(dataset, splitList, testInd=1) { # returns a list with two elements: $test and $cv; the testInd is the index of the testing group, the others are CV
	if (testInd > length(splitList)) {
		stop("The provided testIndex is exceeding the maximum available value from the splitList.", call.= TRUE)
	}
	if (length(testInd) > 1) {
		stop("Test testIndex can not be of length > 1", call.=TRUE)
	}
	if (length(splitList) == 1) { # we might have zero percent as test data
		return(list(cv=dataset, test=NULL))
	}
	cv <- 1: length(splitList)
	cv <- cv[cv != testInd]
	cvInds <- sort(unlist(splitList[cv]))
	testInds <- splitList[[testInd]]
	return(list(cv=dataset[cvInds], test=dataset[testInds]))
} # EOF



# universal looping outer and inner ---------
make_Xclass_model_CV_single <- function(trainDataset, predDataset, classFunc, classOn, type, apCl) { # inside the single steps of the x-fold CV, single models and predictions (in CV)
	dfTrain <- makeDataFrameForClassification(trainDataset, classOn) # ! is not flat
	dfPred <- makeDataFrameForClassification(predDataset, classOn) # ! is not flat
	#
	# possibly use PCA for data reduction
	subtr <- 0
	if (apCl$pcaRed) {
		nc <- apCl$pcaNComp # can be either "max" or the desired numbers
		if (any(nc == "max")) {
			nc <- 1: nrow(dfTrain) - 1
			subtr <- 1
		}
	#	NIR <- scale(dfTrain$NIR, scale=FALSE) # center first, need the centers later
	#	trainCenters <- attr(NIR, "scaled:center", exact=TRUE)
		pcaObTrain <- ChemometricsWithR::PCA(scale(dfTrain$NIR, scale=FALSE))
		NIR <- pcaObTrain$scores[,nc] # replace the NIR, select components via nc
		dfTrain$NIR <- I(NIR)
		#
		NIR <- ChemometricsWithR::project(pcaObTrain, newdata=dfPred$NIR , npc=(length(nc)-subtr))
	#	NIR <- scale(dfPred$NIR, scale=FALSE, center=trainCenters)
	#	pcaObPred <- ChemometricsWithR::PCA(NIR, warn=FALSE)
	#	print(""); print(nc); print(dim(dfTrain$NIR))
	#	print(str(pcaObPred)); wait()
	#	NIR <- ChemometricsWithR::PCA(NIR, warn=FALSE)$scores[,nc]
		dfPred$NIR <- I(NIR)
	}
	#
#	cat("Training:\n"); print(str(dfTrain)); cat("Prediction:\n"); print(str(dfPred))
	mod <-classFunc(dfTrain, apCl)
	pred <- predict(mod, newdata=dfPred) # the prediction of the one left out segment in the model made from all the other segments
	cat("\n"); print(confusion(pred, dfPred$grouping)); cat("\n\n")
#	pred <- predict(mod, newdata=dfTrain) # the prediction of the one left out segment in the model made from all the other segments
#	cat("\n"); print(confusion(pred, dfTrain$grouping)); cat("\n\n")
	return(list(mod=mod, pred=pred))
} # EOF

make_Xclass_models_CV_outer <- function(cvData, classFunc, valid, classOn, type, apCl, stnLoc) { # inner loop via CV: making models and predictions
	if (valid == "LOO") {
		valid <- nrow(cvData)
	}
	segList <- createSegmentListForClassification(cvData$header, nrSegs=valid, classOn, stnLoc) # looks in each group individually
	# now, from this segList, use all except one list elements for training the model, and then the one for prediction --> collect models and predictions (errors)
	modList <- vector("list", length(segList))
	predList <- vector("list", length(segList))
	indPool <- 1: length(segList)
	for (i in 1: length(segList)) { # cycling through the combinations of the n-fold CV
		predInd <- i
		trainInd <- indPool[indPool != predInd]		###### CORE ###### CORE #######
		aa <- make_Xclass_model_CV_single(cvData[ unlist(segList[trainInd]) ], cvData[ unlist(segList[predInd]) ], classFunc, classOn, type, apCl)  # the individual (X-fold) crossvalidation models
		# will be aa, then aa$ from the list...
		modList[[i]] <- aa$mod 
		predList[[i]] <- aa$pred
	} # end for i
	return(modList)
} # EOF

make_Xclass_models_boot <- function(cvData, classFunc, R, classOn, type, apCl, stnLoc) { # inner loop via boot: making  models
	# boot here please
} # EOF

make_Xclass_models_inner <- function(cvData, testData, classFunc, classOn, md, apCl, idString, stnLoc, type) { # in the inner loop: deciding if via boot or not
	cvBootCutoff <- apCl$bootCutoff
	cvBootFactor <- apCl$bootFactor # the factor used for multiplying the number of observations in the group, resulting in the bootR value
	cvValid <- round(apCl$valid, 0) # round just to be sure 
	#
	neverBoot <- stnLoc$cl_gen_neverBootstrapForCV
	clPref <- stnLoc$p_ClassVarPref
	snColName <- stnLoc$p_sampleNrCol 
	snrCol <- paste0(clPref, snColName)
	#
	ind <- which(colnames(cvData$header) == snrCol)
	aa <- lapply(split(cvData$header, cvData$header[,classOn]), function(x) x[,ind]) # split into groups, then get the sampleNr column
	minNrow <-  min(unlist(lapply(aa, length))) #  returns the smallest nr of observations from all separate groups
	if (minNrow >= cvBootCutoff | neverBoot) {
		if (!stnLoc$allSilent) {cat(".")}
		mods <- make_Xclass_models_CV_outer(cvData, classFunc, valid=cvValid, classOn, type, apCl, stnLoc) ##### CORE ######
	} else {
		if (!stnLoc$allSilent) {cat(":")}
		mods <- make_Xclass_models_boot(cvData, classFunc, R=minNrow*cvBootFactor, classOn, type, apCl, stnLoc) ##### CORE ######
	}
	# now mods contains the CV models from either boot or the n-fold CV
	return(mods)
} # EOF

make_X_classif_models <- function(dataset, classFunc, md, apCl, classOn, idString=NULL, stnLoc, type) { # going 1) through the classOn, and 2) outerSplit
	doOuter <- apCl$testCV
	percTest <- apCl$percTest
	if (percTest <= 0 ) {
		doOuter <- FALSE
	}
	#
	outList <- vector("list", length(classOn))
	outListRealClassOn <- vector("list", length(classOn))
	for (k in 1: length(classOn)) {
		splitList <- makeOuterSplitList(dataset, percTest, classOn[k], stnLoc) # new split in CV and TEST data for every classOn variable
		if (!doOuter) {
			modsList <- vector("list", 1)
			realClOnList <- vector("list", 1)
			aa <- makeOuterSplitDatasets(dataset, splitList, testInd=1) # returns a list:  $test and $cv; the smallest dataset is always on place 1 for testing
			if (nlevels(aa$cv$header[,classOn[k]]) < 2) {
				mods <- NULL
				realClOnFill <- NULL
			} else {
				mods <- make_Xclass_models_inner(cvData=aa$cv, testData=aa$test, classFunc, classOn[k], md, apCl, idString, stnLoc, type) ##### CORE ######
				realClOnFill <- classOn[k]
			} # end if
			modsList[[1]] <- mods # filling in the mods for the outer loop
			realClOnList[[1]] <- realClOnFill
		} else {
			modsList <- vector("list", length(splitList))
			realClOnList <- vector("list", length(splitList))
			for (i in 1: length(splitList)) {	
				aa <- makeOuterSplitDatasets(dataset, splitList, testInd=i)	
				if (nlevels(aa$cv$header[,classOn[k]]) < 2) {
					mods <- NULL
					realClOnFill <- NULL
				} else {
					mods <- make_Xclass_models_inner(cvData=aa$cv, testData=aa$test, classFunc, classOn[k], md, apCl, idString, stnLoc, type)	##### CORE ######				
					realClOnFill <- classOn[k]
				}	
				modsList[[i]] <- mods # filling in the mods for the outer loop
				realClOnList[[i]] <- realClOnFill
			} # end for i
		} # end else
		outList[[k]] <- modsList
		outListRealClassOn[[k]] <- realClOnList
	} # end for k
	return(list(modsClOn=outList, realClOn=realClOnList))
} # EOF

make_X_classif_handoverType <- function(dataset, md, apCl, types, idString, priInfo, priTy="") { # going through types; called in cube_makeModels.r; the incoming dataset from the set
	stnLoc=.ap2$stn
	classOn <- apCl$classOn
	#
	if (length(types) == 1) {add <- ""} else {add <- ""}
	outList <- vector("list", length(types))
	outListRealClOn <- vector("list", length(types))
	if (!stnLoc$allSilent) {cat(paste0("      calc. ", priInfo, ":"))}
	for (i in 1: length(types)) {		
		classFunc <- getClassifierFunction(types[i]) ####### here select the desired classifier method !! ######
		if (!stnLoc$allSilent) {cat(paste0(" ", priTy[i], add))}
			###
			aa <- make_X_classif_models(dataset, classFunc, md, apCl, classOn, idString, stnLoc, type=types[i]) ##### make models ###### CORE ######	
			outList[[i]] <- aa$modsClOn
			outListRealClOn[[i]] <- aa$realClOn
			###
	} # end for i
	if (!stnLoc$allSilent) {cat(" ok\n")}
	oid <- paste0(priInfo, "__", idString)
	return(list(modsTy=outList, realClassOn=NA, apCl=apCl, id=oid))
#	return(list(modsTy=outList, realClassOn=outListRealClOn, apCl=apCl, id=oid))
	#
	# the order of the lists, from outer to inner: 
	# daTypes, classOn, outerLoop (=TestCV), CV inner loop, [then list element of individual models]
} # EOF
