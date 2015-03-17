## regarding Aquagram
pv_AquagramModes <- c("classic", "classic-diff", "sfc", "sfc-diff", "aucs", "aucs-diff", "aucs.tn", "aucs.tn-diff", "aucs.tn.dce", "aucs.tn.dce-diff", "aucs.dce",  "aucs.dce-diff")



## plotting the cube
pv_what_subPlots <- c("all", "pca", "sim", "pls", "aqg")


## PCA plotting
pv_pca_what <- c("both", "scores", "loadings")


## Aquagram plotting
pv_fsa_fss <- c("both", "only")

############
## complete possible values for modifying via ...
pv_modifyUCL <- c("spl.var", "spl.wl")
pv_modifyDPT <- c("spl.do.smo", "spl.smo.raw", "spl.do.noise", "spl.noise.raw")
pv_modifyPCA<-c("do.pca", "pca.colorBy", "pca.what", "pca.sc", "pca.sc.pairs", "pca.lo")
pv_modifySIMCA<-c("do.sim", "sim.varsn", "sim.K")
pv_modifyPLSR<-c("do.plt", "pls.regOn", "pls.ncomp", "pls.valid", "pls.colorBy")
pv_modifyAquagram<-c("do.aqg", "aqg.vars", "aqg.nrCorr", "aqg.spectra", "aqg.minus", "aqg.mod", "aqg.TCalib", "aqg.Texp", "aqg.bootCI", "aqg.R", "aqg.smoothN", "aqg.selWls", "aqg.msc", "aqg.reference", "aqg.fsa", "aqg.fss", "aqg.ccol", "aqg.clt", "aqg.pplot", "aqg.plines", "aqg.disc")
pv_modifyGenPlot<-c("pg.where", "pg.main", "pg.sub", "pg.fns")	
pv_tripleDotsMod <- c(pv_modifyUCL, pv_modifyDPT, pv_modifyPCA, pv_modifySIMCA, pv_modifyPLSR, pv_modifyAquagram, pv_modifyGenPlot)
##############

