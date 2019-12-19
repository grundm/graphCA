# Load data with "load_sgl_crs.R"
# or load("~/ownCloud/promotion/experiment/GraphCA/data/img_fMRI/stim_conf_TENT2/sgl_crs_r4.RData")
# load("/data/pt_nro150/mri/group/stim_conf_TENT3/sgl_crs_r4.RData")
# load("/data/pt_nro150/mri/group/all_cond_TENT/sgl_crs_r4.RData")

# install.packages("reshape2")
# install.packages("tidyr")

# FUNCTIONS ---------------------------------------------------------------

#code_dir <- '~/ownCloud/promotion/experiment/GraphCA/graphca'
code_dir <- '/data/pt_nro150/graphca/'

# Get data
source(paste(code_dir, 'mri/load_sgl_crs.R', sep = '/'))


# PLOT ALL ROIs -----------------------------------------------------------

# Get plotting function
source(paste(code_dir, 'mri/plot_sgl_crs.R', sep = '/'))

#pdf('/data/pt_nro150/mri/group/all_cond_conf2_TENT/sgl_crs_hit_CI3.pdf', width=8, height=7.5, useDingbats=FALSE)

for (ROI_str in unique(sna$ROI)) {
  print(ROI_str)
  
  plot_crs(subset(sna, ROI == ROI_str), sn, ROI_str, "topright")
}

#dev.off()


# PCUN --------------------------------------------------------------------

cond_str <- c('CR', 'near_hit_unconf', 'near_hit_conf')
cond_str <- c('CR', 'near_miss_unconf', 'near_miss_conf', 'near_hit_unconf', 'near_hit_conf')
#ROI_str <- 'rPCUN'
ROI_str <- 'PCUN'

for (ROI_str in unique(sna$ROI)) {

  #tp <- c(-3,-2.25,-1.5,-0.75,0)
  
  tp <- c(-2.25,-1.5,-0.75,0)
  
  test_beta<-data.frame(matrix(ncol=length(tp), nrow=length(unique(sn$ID))))
  
  #test_beta_hit<-data.frame(matrix(ncol=length(tp), nrow=length(unique(sn$ID))))
  #test_beta_miss<-data.frame(matrix(ncol=length(tp), nrow=length(unique(sn$ID))))
  
  colnames(test_beta) <- tp
  
  for (i in 1:length(tp)) {
    # test_beta[, i]<-(sn$beta[sn$ROI==ROI_str & sn$cond == cond_str[3] & sn$t == tp[i]]
    #                 - sn$beta[sn$ROI==ROI_str & sn$cond == cond_str[2] & sn$t == tp[i]])
    
    test_beta[, i]<-(sn$beta[sn$ROI==ROI_str & sn$cond == cond_str[3] & sn$t == tp[i]] + sn$beta[sn$ROI==ROI_str & sn$cond == cond_str[5] & sn$t == tp[i]]
                     - sn$beta[sn$ROI==ROI_str & sn$cond == cond_str[2] & sn$t == tp[i]] - sn$beta[sn$ROI==ROI_str & sn$cond == cond_str[5] & sn$t == tp[i]])
    
    #test_beta_hit[, i]<-sn$beta[sn$ROI==ROI_str & sn$cond == cond_str[3] & sn$t == tp[i]]
    
    #test_beta_miss[, i]<-sn$beta[sn$ROI==ROI_str & sn$cond == cond_str[2] & sn$t == tp[i]]
    
  }
  
  tstats <- t.test(rowMeans(test_beta))
  
  print(ROI_str)
  print(tstats$p.value)

}

# cS1 ---------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'cS1'), sn, 'cS1', 'n')

# cS2a --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'cS2a'), sn, 'cS2a', 'n') #topright

# cS2b --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'cS2b'), sn, 'cS2b', 'n') #topright

# iS2 --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'iS2'), sn, 'iS2', 'n') #topright

# lIFG --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'lIFG'), sn, 'Left IFG', 'n') #topleft

# lINS1 --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'lINS1'), sn, 'Left anterior Insula1', 'n') #topleft

# lINS2 --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'lINS2'), sn, 'Left anterior Insula2', 'n') #topleft

# rINS --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rINS'), sn, 'Right anterior Insula', 'topleft')

# lSOG --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'lSOG'), sn, 'Left SOG', 'n') #topleft

# lSPL --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'lSPL'), sn, 'Left SPL', 'topleft')

# rIPL --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rIPL'), sn, 'Right IPL', 'topleft')

# rPCUN --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rPCUN'), sn, 'Right Precuneus', 'topleft')


# lPCUN2 --------------------------------------------------------------------
# No pre-stimulus difference, no difference for aware-control, but unaware-control
plot_crs(subset(sna, ROI == 'lPCUN2'), sn, 'Left Precuneus', 'topleft')

# rSPL --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rSPL'), sn, 'Right SPL', 'n')

# rIFG --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rIFG'), sn, 'Right IFG', 'n') #bottomleft


# lPCC --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'lPCC'), sn, 'Left PCC', 'n')

# lIPL1 --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'lIPL1'), sn, 'Left IPL', 'n')

# rIOG --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rIOG'), sn, 'Right IOG', 'n')

# lACC --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'lACC'), sn, 'Left ACC', 'n')

# rIFG --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rIFG'), sn, 'Right IFG', 'n')

# rMFG --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rMFG'), sn, 'Right MFG', 'n')

# rSFG --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rSFG'), sn, 'Right SFG', 'n')

# rMTG --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rMTG'), sn, 'Right MTG', 'n')

# iS2 --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'iS2a'), sn, 'iS2', 'n')

# rINS --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rINS'), sn, 'Right INS', 'n')

# raINS --------------------------------------------------------------------
# Strong oscilliation
plot_crs(subset(sna, ROI == 'raINS'), sn, 'Right anterior Insula', 'n')

# rpINS --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rpINS'), sn, 'Right posterior Insula', 'n')

# cS1b --------------------------------------------------------------------
# M1? Less pronounced negative signal for aware during and after stimulus onset
plot_crs(subset(sna, ROI == 'cS1b'), sn, 'cS1b', 'n')

# A4b --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'A4b'), sn, 'A4b', 'n')

# A4a --------------------------------------------------------------------
# Very similar to A4b, only aware - unaware get not significant
plot_crs(subset(sna, ROI == 'A4a'), sn, 'A4a', 'n')

# A1_1 --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'A11'), sn, 'A1', 'n')

# A1/2 --------------------------------------------------------------------
# ~ cS1?
plot_crs(subset(sna, ROI == 'A12'), sn, 'A1/2', 'n')

# Blankenburg 2003 A1 --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'A1'), sn, 'Blankenburg 2003 A1', 'n')

# Blankenburg 2003 A3b --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'A3b'), sn, 'Blankenburg 2003 A3b', 'n')