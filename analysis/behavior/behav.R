# GraphCA - Behavioral Data -----------------------------------------------
# Mac OS: "alt + cmd + T" runs section
# Linux: "ctrl + alt + T" runs section

# Prepare data (concatenate all txt files of nt_save)
#cat ID*/nt_*_trials_*.txt > nt_trials_tmp.txt
#sed '2,${/ID*/d}' nt_trials_tmp.txt > nt_trials.txt

rm(list = ls())

# SETTINGS ----------------------------------------------------------------
code_dir <- '/analysis/behavior'
data_dir <- '/analysis/behavior'
code_dir <- getwd()
data_dir <- getwd()

behav_data <- paste(data_dir, '/nt_trials.txt', sep = '')

# PRE-PROCESSING ----------------------------------------------------------

# Load functions
setwd(code_dir)

trial_filter <- dget("trial_filter.R")
block_analyze <- dget("block_analyze.R")
ID_level <- dget("ID_level.R")
ID_level2 <- dget("ID_level2.R")

# Load data
d <- read.table(behav_data, header = TRUE, sep = "\t", fill = TRUE, stringsAsFactors = FALSE)

# Trial level
dt <- trial_filter(d)

  # Special case: ID 38 did not report confidence in block 1-3
  dt$resp_filter[dt$ID==38 & dt$block < 4] <- 0
  
  # Exclude 1st trial in each block, since we removed inital 10 trials
  dt$resp_filter[dt$trial==1] <- 0
  
# Block level
db <- block_analyze(dt)

# Participant level
dID1 <- ID_level(db)

dID_new <- ID_level2(db)


# ONSET TIMES ---------------------------------------------------------

# rm -rf ID*/onsets

onset_t <- dget("onset_t.R")

# Create text files with "stimulus" onset times for each condition, block and ID
#onset_t(dt,db,dID1,data_dir,'onsets')

onset_t(dt,db,dID_new,data_dir,'onsets/new')


# FILTER FOR HITS/MISSES ACCROSS BLOCKS --------------------------------------------------------

# Since number of trials were averaged for blocks
dID_new$null_n <- dID_new$null_n * dID_new$block_num
dID_new$null_conf_n <- dID_new$null_conf_n * dID_new$block_num
dID_new$null_unconf_n <- dID_new$null_unconf_n * dID_new$block_num
dID_new$null_no_conf_n <- dID_new$null_no_conf_n * dID_new$block_num

dID_new$near_n <- dID_new$near_n * dID_new$block_num
dID_new$near_conf_n <- dID_new$near_conf_n * dID_new$block_num
dID_new$near_unconf_n <- dID_new$near_unconf_n * dID_new$block_num

dID_new$near_miss_conf_n <- dID_new$near_miss_conf_n * dID_new$block_num
dID_new$near_miss_unconf_n <- dID_new$near_miss_unconf_n * dID_new$block_num
dID_new$near_hit_unconf_n <- dID_new$near_hit_unconf_n * dID_new$block_num
dID_new$near_hit_conf_n <- dID_new$near_hit_conf_n * dID_new$block_num

dID_new$supra_n <- dID_new$supra_n * dID_new$block_num
dID_new$supra_conf_n <- dID_new$supra_conf_n * dID_new$block_num
dID_new$supra_unconf_n <- dID_new$supra_unconf_n * dID_new$block_num

dID_new$supra_yes_conf_n <- dID_new$supra_yes_conf_n * dID_new$block_num

# Calculate difference for "confident" trials
dID_new$near_conf_n_diff <- dID_new$near_hit_conf_n - dID_new$near_miss_conf_n

# Create filter variables
dID_new$near_conf_n_filter <- ifelse(dID_new$near_hit_conf_n >= 10 & dID_new$near_miss_conf_n >= 10, 1, 0)
#dID_new$near_unconf_n_filter <- ifelse(dID_new$near_hit_unconf_n >= 10 & dID_new$near_miss_unconf_n >= 10, 1, 0)
dID_new$near_unconf_n_filter <- ifelse(dID_new$near_hit_unconf_n >= 1 & dID_new$near_miss_unconf_n >= 1, 1, 0)

dID_new2 <- subset(dID_new, near_conf_n_filter == 1 & near_unconf_n_filter == 1)

# ANALYSIS NUMBER OF CONFIDENT HITS & MISSES --------------------------------------------------

sum(dID_new2$near_hit_conf_n)
# 623
sum(dID_new2$near_miss_conf_n)
# 594

mean(dID_new2$near_hit_conf_n)
# 29.67
mean(dID_new2$near_miss_conf_n)
# 28.29

range(dID_new2$near_hit_conf_n)
# 13-52
range(dID_new2$near_miss_conf_n)
# 11-53

# T test number of confident hits and misses
t.test(dID_new2$near_miss_conf_n, dID_new2$near_hit_conf_n, paired = TRUE)
# t(20)= -0.42, p = 0.68

boxplot(dID_new2$near_miss_conf_n, dID_new2$near_hit_conf_n)
