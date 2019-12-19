# SETTINGS ----------------------------------------------------------------

data_path <- '/data/pt_nro150/mri'

ID_dir_wildcard <- 'ID[0-9][0-9]'

signal_course_dir <- 'glm/all_cond_conf2_TENT/signal_course_r4' # EDIT #
#signal_course_dir <- 'glm/all_cond_TENT/signal_course_r4' # EDIT #

cond_str <- c('CR_conf', 'near_miss_conf', 'near_hit_conf') # EDIT #
cond_str <- c('CR_conf', 'near_miss_unconf', 'near_miss_conf', 'near_hit_unconf', 'near_hit_conf') # EDIT #
#cond_str <- c('CR', 'near_miss', 'near_hit') # EDIT #

#time_points <- seq(-6,12,1.5)
time_points <- seq(-6,12,0.75)

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
  sgl[[i]]$t <- time_points
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

#sn <- subset(sn, sn$cond==cond_str[1] | sn$cond==cond_str[2] | sn$cond==cond_str[3])

sna <- summarySEwithin(data=sn, 'beta', betweenvars='ROI', withinvars=c('cond','t'),
                       idvar='ID', na.rm=FALSE, conf.interval=.95, .drop=TRUE)

sna <- with(sna, sna[order(ROI,cond,t), ])

# REARANGE DATA -----------------------------------------------------------

# # Loop time courses per ROI x condition
# for (ROI_cond in names(sgl[[1]])) {
#   
#   if (ROI_cond != "ID") {
#     
#     # Loop participants
#     for (i in 1:length(sgl)) {
#       
#       # Get signal course data for current ROI x condition
#       crs <- sgl[[i]][ROI_cond]
#       
#       # Rename column to reflect ID rather ROI x condition
#       colnames(crs) <- unique(sgl[[i]]$ID)
#       
#       if (i == 1) {
#         d <- crs
#       }
#       else {
#         d[ , colnames(crs)] <- crs
#       }
#       
#     }
#     
#     assign(ROI_cond, d)
#   }
# }