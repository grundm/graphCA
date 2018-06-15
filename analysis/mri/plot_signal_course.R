# Load data with "load_sgl_crs.R"
# or load("sgl_crs_r4.RData")

# FUNCTIONS ---------------------------------------------------------------

code_dir <- '/analysis/mri'
code_dir <- getwd()

# Get data
#source(paste(code_dir, 'mri/load_sgl_crs.R', sep = '/'))

# Get plotting function
source(paste(code_dir, 'mri/plot_sgl_crs.R', sep = '/'))

# lPCUN1 --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'lPCUN1'), sn, 'Left Precuneus', 'topleft')

# rSPL --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rSPL'), sn, 'Right SPL', 'n')

# cS1 ---------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'cS1'), sn, 'cS1', 'n')

# cS2a --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'cS2a'), sn, 'cS2', 'n') #topright

# rMFG --------------------------------------------------------------------

plot_crs(subset(sna, ROI == 'rMFG'), sn, 'Right MFG', 'n')
