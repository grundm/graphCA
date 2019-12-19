# GraphCA - Behavioral Data -----------------------------------------------
# Mac OS: "alt + cmd + T" runs section
# Linux: "ctrl + alt + T" runs section

# Prepare data (concatenate all txt files of nt_save)
#cat ID*/nt_*_trials_*.txt > nt_trials_tmp.txt
#sed '2,${/ID*/d}' nt_trials_tmp.txt > nt_trials.txt

rm(list = ls())

# SETTINGS ----------------------------------------------------------------
code_dir <- '~/ownCloud/promotion/experiment/GraphCA/manuscript/repository/graphCA/analysis/behavior'
data_dir <- '~/ownCloud/promotion/experiment/GraphCA/manuscript/repository/graphCA/analysis/behavior'
#code_dir <- getwd()
#data_dir <- getwd()

behav_data <- paste(data_dir, '/nt_trials.txt', sep = '')

# PRE-PROCESSING ----------------------------------------------------------

# Load functions
setwd(code_dir)

trial_filter <- dget("trial_filter.R")
block_analyze <- dget("block_analyze.R")
ID_level <- dget("ID_level.R")

# Load data
d <- read.table(behav_data, header = TRUE, sep = "\t", fill = TRUE, stringsAsFactors = FALSE)

# Trial level
dt <- trial_filter(d)

  # Special case: ID 38 did not report confidence in block 1-3
  dt$resp_filter[dt$ID==38 & dt$block < 4] <- 0
  
  # Exclude 1st trial in each block, since we removed inital 10 brain volumes
  dt$resp_filter[dt$trial==1] <- 0
  
# Block level
db <- block_analyze(dt)

# Participant level
dID1 <- ID_level(db)


# ONSET TIMES ---------------------------------------------------------

# rm -rf ID*/onsets

onset_t <- dget("onset_t.R")

# Create text files with "stimulus" onset times for each condition, block and ID
onset_t(dt,db,dID1,data_dir,'onsets/new3',FALSE)


# COVARIATES --------------------------------------------------------------

file_MEMA = '/data/pt_nro150/mri/group/cov_file.txt'
file_ttest = '/data/pt_nro150/mri/group/cov_file_ttest.txt'

# 3dttest++ & 3dMEMA want different headers for the covariate files
write(c('subj', 'near_yes'), file_MEMA, ncolumns = 2, sep = "\t")
write(c('subject', 'near_yes'), file_ttest, ncolumns = 2, sep = "\t")


for (i in unique(dID1$ID)) {
  ifelse(i < 10, ID_str <- paste('0', i, sep = ''), ID_str <- i)
  
  cov_arr <- c(ID_str,  round(dID1$near_yes[dID1$ID==i],4))

	# 3dttest++ needs individual filenames because "gen_group_command.py" is not used 
  cov_arr_ttest <- c(paste(ID_str, '_glm_REML', sep = ''),  round(dID1$near_yes[dID1$ID==i],4))
  
  write(cov_arr, file_MEMA, ncolumns = length(cov_arr), append = TRUE, sep = "\t")
  
  write(cov_arr_ttest, file_ttest, ncolumns = length(cov_arr_ttest), append = TRUE, sep = "\t")
  
}
