# SETTINGS ----------------------------------------------------------------

data_path <- '/data/pt_nro150/mri'

ID_dir_wildcard <- 'ID[0-9][0-9]'

signal_course_dir <- 'glm/stim_conf_TENT/signal_course_r4'

# For within CI/SE

code_dir <- '/data/pt_nro150/graphca/'

# Get within variance estimate helper functions
source(paste(code_dir, 'assets/CI_within_helper.R', sep = '/'))

library(reshape2)
library(tidyr)


# READ TEXT FILES ---------------------------------------------------------

# Prepare list to collect participant's data frames
sgl <- list()

# Get all participant directories
ID_dir <- dir(data_path, ID_dir_wildcard)
i <- 1

# Loop participants
for (ID in ID_dir) {
  
  # Check if GLM with signal course data exists
  sgnl_crs_pth <- paste(data_path, ID, signal_course_dir, sep = '/')
  
  if (file.exists(sgnl_crs_pth)) {
    
    print(ID)
    
    # Get all signal course data files
    sgnl_crs_files <- dir(sgnl_crs_pth)
    
    # Loop a signal course data files
    for (j in 1:length(sgnl_crs_files)) {
      
      if (j == 1) {
        d <- read.table(paste(sgnl_crs_pth, sgnl_crs_files[j], sep = "/"),
                        col.names = tools::file_path_sans_ext(sgnl_crs_files[j]))
      }else {
        d[ ,tools::file_path_sans_ext(sgnl_crs_files[j])] <- read.table(paste(sgnl_crs_pth, sgnl_crs_files[j], sep = "/"),
                                                                        col.names = tools::file_path_sans_ext(sgnl_crs_files[j]))  
      }
    }
    
    # Save participant's data
    sgl[[i]] <- d
    
    # Save ID
    sgl[[i]]$ID <- ID
    
    i <- i + 1
  }
}

# WITHIN CI -----------------------------------------------------------

# Add column with time point counter
for (i in c(1:length(sgl))) {
  sgl[[i]]$t <- seq(-6,12,1.5)
}

# Transform to long format
sn <- melt(sgl, id.vars = c('ID', 't'), value.name = 'beta')

# Remove participant counter in sgl
sn$L1 <- NULL

# Split in ROI (e.g., cS1) and stimulus condition (e.g., near_hit_conf)
sn <- separate(sn, variable, into = c('ROI','cond'), sep = '_', extra = 'merge')

# Split ID string to create integer
sn <- separate(sn,ID,into = c('ID_str','ID'), sep = 'ID')
sn$ID_str <- NULL
sn$ID <- as.integer(sn$ID)

# Prepare
sn$ROI <- as.factor(sn$ROI)
sn$cond <- as.factor(sn$cond)
sn$t <- as.factor(sn$t)

sna <- summarySEwithin(data=sn, 'beta', betweenvars='ROI', withinvars=c('cond','t'),
                       idvar='ID', na.rm=FALSE, conf.interval=.95, .drop=TRUE)

sna <- with(sna, sna[order(ROI,cond,t), ])
