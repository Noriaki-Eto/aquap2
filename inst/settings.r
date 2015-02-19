###########################################################################################
######################## Settings file for package "aquap2" #########################
###########################################################################################

stn <- list(
	# tag = value,
	
	
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
	fn_anProcDefFile = "anProc.r", 			## the default filename for the analysis procedure file

	
	## data preparation, standard column names & prefixes
	p_yVarPref = "Y_", 						## the prefix for numerical variables	
	p_ClassVarPref = "C_",					## the prefix for class-variables
	p_timeCol = "Time", 					## the name of the column containing the time-points (if any)
	p_sampleNrCol = "SampleNr", 			## the name of the column containing the number of the sample in the list, automatically generated
	p_conSNrCol= "ConSNr",					## the name of the second column containing the number of the consecutive scan, automatically generated
	p_ECRMCol = "ECRM", 					## the name of the column holding the class for indicating either environmental control or real measurement
	p_tempCol = "Temp",						## the name of the column holding the room temperature at which the measurements were taken
	p_RHCol ="RelHum",						## the name of the column holding the relative humidity at which the measurements were taken 
	p_expNameCol = "ExpName",				## the name of the column holding the experiment name 
	p_commonNoSplitCol = "noSplit", 		## the name of the column containing the common "no-split" value
	p_commonNoSplit = "noSplit", 			## a common value for all the rows in the dataset in the "noSplit" column
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
	autoUpdateSettings = TRUE, 				## if the settings should be automatically updated when calling a function from package 'aquap2'
	numberOfCPUs = 7, 						## the number of CPUs used for parallel computing


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




	### smoothing ###
	## settings for the Sav. Golay filter at the smoothing process
	savGolayOrder_p = 2, 					## default is 3
	savGolayLength_n = 25,					## default is 5
	savGolayDeriv_m = 0, 					## default is 0



	### Misc: Values for time-estimates etc. 
	#### misc
	misc_durationSingleScan = 33, 			## time in seconds needed for a single scan
	misc_handlingTime = 173, 				## the time needed for handling the cuvette, samples, etc.. (in seconds)


	##
	last = 0
	## the last one without comma !!
) # end of list
