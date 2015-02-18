#' 	@title The Metadata File
#'	@description The metadata file contains all the metadata of an experiment 
#' 	like experiment name etc. It is also used to design the experiment and 
#'	to export a randomized sample list that then can be used in the data 
#'  acquisition process.
#'  @details The classes and their sub-classes can be defined in the L1 and L2 
#'  lists, XXX explain thiss !!! Some looks at the provided XXX examples will 
#'  soon make the system clear.
#'  @param experimentName The name of the experiment. Will be used in many plot 
#'  titles and as a first part of the name of saved PDFs.
#'  @param commonValue Character. A value that will be be present in all the rows 
#'  of the dataset. This is useful to have in some cases. The default 'def' reads 
#'  in the default value from the settings.r file.
#'  @param TimePoints Logical 'FALSE' or a character vector. Leave at 'FALSE' if 
#'  your experiment does not cover more than one point in time, otherwise provide 
#'  a label for every point in time like e.g. c("T1", "T2", "T3")
#'  @param nrConScans Numeric length one. Home many consecutive scans of each 
#'  sample.
#'  @param spacing Numeric length one. The number of "real measurements" between 
#'  each "environmental control".
#'  @param envControlLabel Character. The label for the enironmental control. 
#'  The default 'def' reads in the default value from the settings.r file.
#'  @param realMeasurementLabel Character. The label for the "real measurements". 
#'  The default 'def' reads in the default value from the settings.r file.
#'  @param columnNamesL1 Character vector. The column names for the L1-variables.
#'  @param columnNamesL2 Character vector. The column names for the L2-variables, 
#'  they have to have the same length as the L1 column names.
#'  @param L1 A list, containing a list for each L1-variable.
#'  @param L2 A list, containing a lsit for each L2-variable.
#'  @param Repls Numeric. How many replicates of each sample to measure. The values 
#'  in the dataset wil be prefixed with the default character for the replicates, 
#'  which can be set in the settings (default is "R"). So, with e.g. three 
#'  replicates you will find the values "R1", "R2", and "R3" in the dataset.
#'  @param Group Character vector. Additional "multiplication" of the so far established 
#'  variables into the provided groups (e.g. c("Exp", "Cont") for "Experiment" 
#'  and "Control")
#'  @seealso \code{\link{getmd}}
#'  @family fileDocs
#'  @name metadata_file
NULL
