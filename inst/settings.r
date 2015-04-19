###########################################################################################
######################## Settings file for package "aquap2" #########################
###########################################################################################

stn <- list(
	# tag = value, # with a comma !!
	
	
	## Folder Management
	fn_analysisData = "anData",				## the folder name for storing any analysis data
	fn_exports = "exports", 				## the folder name for any exported file
	fn_rcode = "R-code", 					## the folder where all the r-code is kept
	fn_rawdata = "rawdata", 				## the folder where you put the raw-data from your data acquisition
	fn_rdata = "R-data", 					## the folder where R is keeping all its raw-data after importing from the data-acquisition format
	fn_metadata = "metadata", 				## the folder where you put the metadata and the analysis procedure r-files
	fn_results = "results",					## the folder where all the result-pdfs get saved
	fn_sampleLists = "sampleLists", 		## the folder for the sample lists used in randomizing the samples and for importing the raw-data
	fn_sampleListOut = "sl_out", 			## the folder holding the sample lists that have been generated by package 'aquap2' and that contain the samples in a randomized order
	f_sampleListIn = "sl_in", 				## the folder holding the sample list *after* the measurements, where Temp and rel. humidity values could be filled in manually if not logger was available.
	fn_mDataDefFile = "metadata.r", 		## the default filename for the metadata file
	fn_anProcDefFile = "anproc.r", 			## the default filename for the analysis procedure file

	
	## data preparation, standard column names & prefixes
	p_yVarPref = "Y_", 						## the prefix for numerical variables	
	p_ClassVarPref = "C_",					## the prefix for class-variables
	p_timeCol = "Time", 					## the name of the column containing the time-points (if any)
	p_sampleNrCol = "SampleNr", 			## the name of the column containing the number of the sample in the list, automatically generated
	p_conSNrCol= "conSNr",					## the name of the second column containing the number of the consecutive scan, automatically generated
	p_ECRMCol = "ECRM", 					## the name of the column holding the class for indicating either environmental control or real measurement
	p_tempCol = "Temp",						## the name of the column holding the room temperature at which the measurements were taken
	p_RHCol ="RelHum",						## the name of the column holding the relative humidity at which the measurements were taken 
	p_userDefinedSpecialColnames = c("Conc", "Weight"),		## the special column names where the colors defined in "col_userDefinedRamps" will be used
	p_expNameCol = "ExpName",				## the name of the column holding the experiment name 
	p_commonNoSplitCol = "all", 			## the name of the column containing the common "no-split" value
	p_commonNoSplit = "all", 				## a common value for all the rows in the dataset in the "noSplit" column
	p_envControlLabel = "MQ", 				## the default label for the environmental control
	p_realMeasurementLabel = "RM", 			## the default label for the "real measurement", for all the samples of your experiment
	p_replicatePrefix = "R", 				## the prefix for the value indicating the number of the replicate of a measurement, so e.g. with the default 'R' you will have your replicates named "R1", "R2", "R3", ...
	p_replicateCol = "Repl", 				## the name of the column containing the replicates
	p_groupCol = "Group", 					## the name of the column containing the groups (like e.g. experiment and control)
	p_deleteCol = "DELETE", 				## the character indicating that this column should be omitted at the time of creating the sample list, usually needed for L2-columns that are identical to their L1-columns
	p_noTimePointsLabel = "NT", 			## the value assigned to every observation when there is no splitting into time points
	p_sampleListExportFormat = "csv", 		## the format for the generated sample list, possible values are "txt" for a tab-delimited text file and "xls" for an Excel-file.


	## General behaviour & settings
	allSilent = FALSE,						## if false, "status" messages will be displayed
	autoUpdateSettings = TRUE, 				## if the settings should be automatically updated when calling a function from package 'aquap2'. Recommended value is TRUE.
	gen_numberOfCPUs = NA, 					## the number of CPUs used for parallel computing; leave at 'NA' for automatically using the system defaults
	gen_showData_NIR = FALSE, 				## if the first rows of the NIR data should be printed as well wenn printing an object of class 'aquap_data' to the screen.


	## Import Data
	imp_specFileType = "vision_NSAS.da",	## the filetype of the spectral data. Refer to the help for 'getFullData'  for possible values
	imp_startDate = "2014-06-01 00:00:00",	## the start-date used to calculate the absolute number of minutes since then
	imp_sampleListType = "csv", 			## the filetype of the sample list in the sampleLists/sl_in folder. Please refer to the help for "getFullData" for possible values.
	imp_multiplyRows = TRUE,				## if all the rows in the sample list should be multiplied by the number of consecutive scans.
	imp_autoCopyYvarsAsClass = TRUE, 		## if all available Y-Variables should be automatically copied as a class variable at the time of importing the data. Recommended value is TRUE.
	imp_TClassesDiv = 5,					## the number by which the temperature values get divided, then rounded, then multiplied
	imp_RHClassesDiv = 3,					## the number by which the rel. humidity values get divided, then rounded, then multiplied
	imp_TRounding = 1,  					## digits precision for rounding when re-factoring the temperature
	imp_RHRounding = 0, 					## digits precision for rounding when re-factoring the rel. humidity
	imp_makeExpNameColumn = FALSE, 			## if a column containing the name of the experiment in every row should be added to the dataset. This is useful if you plan to fuse datasets from several experiments.
#	imp_makeNoSplitColumn = TRUE, 			## if a column containing the same value in every row should be added to the dataset. This can be useful to have in the operations for data splitting.
	imp_makeTimeDistanceColumn = TRUE, 		## if, should a timestamp be available, a column with the time-distance from a user-defined point in time and an other with the chronological order (1:nrow enumeration) should be generated
	imp_use_TRH_logfile = "ESPEC", 			## if and how values for temperature and relative humidity should be imported from an external logfile. See the help for 'getFullData' for information on possible values
	imp_TRH_logfile_name = "TRHlog", 		## the name of the logfile for temperatur and rel.humidity in the rawdata folder.
	imp_narrowMinutes = 3, 					## how many minutes ahead should be looked for matching log-data before going through the whole log file?
	imp_secsNarrowPrecision = 10, 			## precision in seconds that log-data have to be within spectral acquisition time in the first, the narrowed-down search step (there is no precision step in the second search through the whole log file)
	imp_minutesTotalPrecision = 3, 			## the final precision in minutes that the log-data have to meet; if only for one spectrum under this value importing will be aborted


	## generate Datasets
	gd_keepECs = TRUE,						## if the environmental controls should be kept in the dataset when splitting after the provided variables.


	## Colors
	col_RampForTRH = c("blue", "red", "yellow2"), 	## used for color-coding any column that contains the characters defined as names for the temperature and rel. humidity column. Provide at least two colors.
	col_userDefinedRamps = list(c("green", "red"), c("blue", "yellow2")), 	## used for coloring the in "p_userDefinedSpecialColnames" defined special column names.   XXX make nicer colors here

	### smoothing ###
	## settings for the Sav. Golay filter at the smoothing process
	sm_savGolayOrder_p = 2, 				## 
	sm_savGolayLength_n = 25,				## 
	sm_savGolayDeriv_m = 0, 				## 


	## noise
	noi_noiseLevel = 1e-6, 					## the system-specific noise level XXX 


	## PCA
	pca_nrDigitsVariance = 3, 				## rounding for the display of explained variances in PCA plots
	pca_CI_ellipse_robust = TRUE,			## logical (TRUE or FALSE); if the CI-ellipse in PCA score plots should be calculated robust or not
	pca_CI_ellipse_centerPch = "X",			## the character in the center of a cluster in PCA score plots
	pca_CI_ellipse_lty = c(1,2),			## the linetypes (get recycled) of the CI-ellipses
	pca_CI_ellipse_lwd = 1, 				## the line width of the CI-ellipse
	
	
	## Aquagram 
	aqg_defaultMod = "aucs.dce", 		## the default mode for the Aquagram
	aqg_wlsAquagram = c(1342, 1364, 1374, 1384, 1412, 1426, 1440, 1452, 1462, 1476, 1488, 1512), 	## the wavelengths for the classic aquagram (argument aqg.selWls)
	aqg_nrDigitsAquagram = 2,				## the number of digits displayed in the standard aquagram
	aqg_linetypes = c(1,2,3),				## the default vector for the line-types to be used in the aquagram. Gets recycled.
	aqg_correctNrOfObs = FALSE,				## if the number of observations in each spectral pattern should be corrected (if necessary by random sampling) so that all the spectral pattern are calculated out from the same number of observations
	aqg_adPeakPlot = TRUE,					## if, should subtraction spectra be plotted, an additional plot with picked peaks should be added
	aqg_AdLines = TRUE, 					## if the additional lines should be added to the plot (see XXX for details)
	aqg_discrim = FALSE, 					## if, should subtraction spectra be plotted, it will be discriminated between "true" or "not true" positive peaks
	aqg_defaultMod= "aucs.dce", 			## the default mode for the aquagram. See the help for XXX for possible values.
	aqg_bootCI = FALSE, 					## if confidence intervalls for the selected wavelengths should be calculated within each group (using bootstrap)
	aqg_bootUseParallel = TRUE, 			## if, should the CIs be calculated, this should be done in parallel
	aqg_bootR = "nrow@3",					## if aqg_bootCI = TRUE, how many bootstrap replicates should be performed? leave at "nrow@3" for e.g. 3 x nrow(samples) or provide a length one numeric
	aqg_saveBootRes = TRUE, 				## if the bootstrap result should be saved under "bootResult" to the analysis-data folder
	aqg_smoothCalib = 17,					## the smoothing (sav. golay) applied for the aucs ("area-under-the-curve-stabilization") calibration data
	aqg_calibTRange = "symm@2", 			## the temperatur range picked out from the calibration data. Either numeric length two [e.g. c(28,32)], or character starting with 'symm@x', with 'x' being the plus and minus delta in temperature from the temperature of the experiment
	aqg_Texp = 28.6,						## the temperature at which the measurements were done
	aqg_OT = "1st",							## what overtone (in development, leave at "1st")
	aqq_nCoord = 12,	 					## only applies to the 1st overtone: how many coordinates to plot (can be 12 or 15)
	
	
	
	## plotting PDFs
	pdf_Height_ws = 5,						## when plotting to pdf, the settings for the format
	pdf_Width_ws = 8.9,						## ws for widescreen (e.g. regressionvector, loading plots, raw)
	pdf_Height_sq = 9,						## sq for square (e.g. scoreplots)
	pdf_Width_sq = 9, 



	### Misc: Values for time-estimates etc. 
	#### misc
	misc_durationSingleScan = 33, 			## time in seconds needed for a single scan
	misc_handlingTime = 173, 				## the time needed for handling the cuvette, samples, etc.. (in seconds)
	##
	last = 0
	## the last one without comma !!
) # end of list
