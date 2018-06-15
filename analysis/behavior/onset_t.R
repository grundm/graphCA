function (dt, db, dID, output_path, output_dir) {

# SETTINGS ----------------------------------------------------------------

f_set = list()  

f_set$output_path <- output_path 
f_set$output_dir <- output_dir
f_set$suffix <- '.1D'


# FUNCTIONS ---------------------------------------------------------------

write_onset <- function (onset_t,f_set) {

  # Write out NA if no values
  ifelse(!length(onset_t), out <- '*', out <- onset_t)
  
  write(out, paste(f_set$path, '/', f_set$ID_str, '_', deparse(substitute(onset_t)), f_set$suffix, sep=''), ncolumns = ifelse(length(onset_t),length(onset_t),1), append = TRUE, sep='\t')

}

create_dir <- function(ID,f_set) {
  
  ifelse(ID < 10, f_set$ID_str <- paste('0', ID, sep = ''), f_set$ID_str <- ID)
  
  f_set$path <- paste(f_set$output_path, '/ID', f_set$ID_str, '/', f_set$output_dir, sep = '')
  
  if (!dir.exists(f_set$path)) { dir.create(f_set$path, recursive = TRUE) }
  
  return(f_set)
}

# ALL PARTICIPANTS --------------------------------------------------------
# Only trial level filter

for (i in unique(dt$ID)) {
  
  f_set <- create_dir(i,f_set)
  
  for (j in sort(unique(dt$block[dt$ID == i]))) {
    
    # Stimulus conditions independent of response
    null_all_t <- dt$stim_onset[dt$ID == i & dt$block == j & dt$stim_type == 0]
    near_all_t <- dt$stim_onset[dt$ID == i & dt$block == j & dt$stim_type == 1]
    supra_all_t <- dt$stim_onset[dt$ID == i & dt$block == j & dt$stim_type == 2]
    stim_all_t <- dt$stim_onset[dt$ID == i & dt$block == j & dt$stim_type != 0]
    
    write_onset(null_all_t,f_set)
    write_onset(near_all_t,f_set)
    write_onset(supra_all_t,f_set)
    write_onset(stim_all_t,f_set)
    
    # Response onsets
    block_onset_t <- dt$mri_trigger[dt$ID == i & dt$block == j][1]
    
    resp1_all_t <- dt$onset_resp1[dt$ID == i & dt$block == j & dt$resp_filter] + dt$resp1_t_corr[dt$ID == i & dt$block == j & dt$resp_filter] - block_onset_t
    resp2_all_t <- dt$onset_resp2[dt$ID == i & dt$block == j & dt$resp_filter] + dt$resp2_t_corr[dt$ID == i & dt$block == j & dt$resp_filter] - block_onset_t

    write_onset(resp1_all_t,f_set)
    write_onset(resp2_all_t,f_set)
  }
  
}

# FILTERED PARTICIPANTS ---------------------------------------------------
# Only the ones that surived last filter step "ID_level.R")

for (i in dID$ID) {
  
  f_set <- create_dir(i,f_set)
  
  # Retrieve valid blocks
  valid_blocks <- as.numeric(unlist(strsplit(as.character(dID$valid_blocks[dID$ID == i]),"")))
  
  write_onset(valid_blocks,f_set)
  
  # Loop blocks
  for (j in valid_blocks) {
    
    block_onset_t <- dt$mri_trigger[dt$ID == i & dt$block == j][1]
      
    # Trial & response screen onset
    trial_t <- dt$mri_trigger[dt$ID == i & dt$block == j] - block_onset_t
    resp1_screen_t <- dt$onset_resp1[dt$ID == i & dt$block == j] - block_onset_t
    
    write_onset(trial_t,f_set)
    write_onset(resp1_screen_t,f_set)
    
    # Near & supra stimuli onsets (independent of valid response)
    stim_t <- dt$stim_onset[dt$ID == i & dt$block == j & dt$stim_type != 0]
    
    write_onset(stim_t,f_set)
  
    # Subset of valid trials
    dt_valid <- subset(dt, ID == i & block == j & resp_filter)
    
    # STIMULUS CONDITION ONSETS -----------------------------------------------
    # For each condition (null/catch, near-threshold, supra-threshold) same structue
    # (1) Stimulus onset for condition in general (given valid response), e.g. near_t
    # (2) Onset splitted for response (yes or no), e.g. near_hit_t
    # (3) Onsets splitted for response (yes/no) and confidence, e.g. near_hit_conf_t
    
    # NULL - Correct rejections & false alarms
    null_t <- dt_valid$stim_onset[dt_valid$stim_type == 0]
    
    CR_t <- dt_valid$stim_onset[dt_valid$stim_type == 0 & dt_valid$resp1 == 0]
    FA_t <- dt_valid$stim_onset[dt_valid$stim_type == 0 & dt_valid$resp1 == 1]
      
    CR_conf_t <- dt_valid$stim_onset[dt_valid$stim_type == 0 & dt_valid$resp1 == 0 & dt_valid$resp2 >= 3]
    CR_unconf_t <- dt_valid$stim_onset[dt_valid$stim_type == 0 & dt_valid$resp1 == 0 & dt_valid$resp2 <= 2]
    
    FA_conf_t <- dt_valid$stim_onset[dt_valid$stim_type == 0 & dt_valid$resp1 == 1 & dt_valid$resp2 >= 3]
    FA_unconf_t <- dt_valid$stim_onset[dt_valid$stim_type == 0 & dt_valid$resp1 == 1 & dt_valid$resp2 <= 2]
    
    write_onset(null_t,f_set)
    
    write_onset(CR_t,f_set)
    write_onset(FA_t,f_set)
    
    write_onset(CR_conf_t,f_set)
    write_onset(CR_unconf_t,f_set)
    
    write_onset(FA_conf_t,f_set)
    write_onset(FA_unconf_t,f_set)
    
    # NEAR - Hits and misses
    near_t <- dt_valid$stim_onset[dt_valid$stim_type == 1]
    
    near_miss_t <- dt_valid$stim_onset[dt_valid$stim_type == 1 & dt_valid$resp1 == 0]
    near_hit_t <- dt_valid$stim_onset[dt_valid$stim_type == 1 & dt_valid$resp1 == 1]
    
    near_miss_conf_t <- dt_valid$stim_onset[dt_valid$stim_type == 1 & dt_valid$resp1 == 0 & dt_valid$resp2 >= 3]
    near_hit_conf_t <- dt_valid$stim_onset[dt_valid$stim_type == 1 & dt_valid$resp1 == 1 & dt_valid$resp2 >= 3]
    
    near_miss_unconf_t <- dt_valid$stim_onset[dt_valid$stim_type == 1 & dt_valid$resp1 == 0 & dt_valid$resp2 <= 2]
    near_hit_unconf_t <- dt_valid$stim_onset[dt_valid$stim_type == 1 & dt_valid$resp1 == 1 & dt_valid$resp2 <= 2]
    
    write_onset(null_t,f_set)
    
    write_onset(near_miss_t,f_set)
    write_onset(near_hit_t,f_set)
    
    write_onset(near_miss_conf_t,f_set)
    write_onset(near_hit_conf_t,f_set)
    
    write_onset(near_miss_unconf_t,f_set)
    write_onset(near_hit_unconf_t,f_set)
    
    # SUPRA - Hits and misses
    supra_t <- dt_valid$stim_onset[dt_valid$stim_type == 2]
    
    supra_miss_t <- dt_valid$stim_onset[dt_valid$stim_type == 2 & dt_valid$resp1 == 0]
    supra_hit_t <- dt_valid$stim_onset[dt_valid$stim_type == 2 & dt_valid$resp1 == 1]
    
    supra_miss_conf_t <- dt_valid$stim_onset[dt_valid$stim_type == 2 & dt_valid$resp1 == 0 & dt_valid$resp2 >= 3]
    supra_hit_conf_t <- dt_valid$stim_onset[dt_valid$stim_type == 2 & dt_valid$resp1 == 1 & dt_valid$resp2 >= 3]
    
    write_onset(supra_t,f_set)

    write_onset(supra_miss_t,f_set)
    write_onset(supra_hit_t,f_set)
        
    write_onset(supra_miss_conf_t,f_set)
    write_onset(supra_hit_conf_t,f_set)
    
    # RESPONSE ONSETS ---------------------------------------------------------
    
    resp1_t <- dt_valid$onset_resp1 + dt_valid$resp1_t_corr - block_onset_t
    resp2_t <- dt_valid$onset_resp2 + dt_valid$resp2_t_corr - block_onset_t
    resp1_resp2_t <- sort(c(resp1_t, resp2_t))
    
    write_onset(resp1_t,f_set)
    write_onset(resp2_t,f_set)
    write_onset(resp1_resp2_t,f_set)
    
    no_t <- dt_valid$onset_resp1[dt_valid$resp1 == 0] + dt_valid$resp1_t_corr[dt_valid$resp1 == 0] - block_onset_t
    yes_t <- dt_valid$onset_resp1[dt_valid$resp1 == 1] + dt_valid$resp1_t_corr[dt_valid$resp1 == 1] - block_onset_t
    
    write_onset(no_t,f_set)
    write_onset(yes_t,f_set)
    
    no_resp2_t <- c(no_t, resp2_t)
    yes_resp2_t <- c(yes_t, resp2_t)
    
    write_onset(no_resp2_t,f_set)
    write_onset(yes_resp2_t,f_set)
    
    c1_t <- dt_valid$onset_resp2[dt_valid$resp2 == 1] + dt_valid$resp2_t_corr[dt_valid$resp2 == 1] - block_onset_t
    c2_t <- dt_valid$onset_resp2[dt_valid$resp2 == 2] + dt_valid$resp2_t_corr[dt_valid$resp2 == 2] - block_onset_t
    c3_t <- dt_valid$onset_resp2[dt_valid$resp2 == 3] + dt_valid$resp2_t_corr[dt_valid$resp2 == 3] - block_onset_t
    c4_t <- dt_valid$onset_resp2[dt_valid$resp2 == 4] + dt_valid$resp2_t_corr[dt_valid$resp2 == 4] - block_onset_t
    
    write_onset(c1_t,f_set)
    write_onset(c2_t,f_set)
    write_onset(c3_t,f_set)
    write_onset(c4_t,f_set)
    
    # BUTTON ONSETS ---------------------------------------------------------
    
    resp1_b6_t <- dt_valid$onset_resp1[dt_valid$resp1_btn == 6] + dt_valid$resp1_t_corr[dt_valid$resp1_btn == 6] - block_onset_t
    resp1_b7_t <- dt_valid$onset_resp1[dt_valid$resp1_btn == 7] + dt_valid$resp1_t_corr[dt_valid$resp1_btn == 7] - block_onset_t
    
    write_onset(resp1_b6_t,f_set)
    write_onset(resp1_b7_t,f_set)
    
    resp2_b5_t <- dt_valid$onset_resp2[dt_valid$resp2_btn == 5] + dt_valid$resp2_t_corr[dt_valid$resp2_btn == 5] - block_onset_t
    resp2_b6_t <- dt_valid$onset_resp2[dt_valid$resp2_btn == 6] + dt_valid$resp2_t_corr[dt_valid$resp2_btn == 6] - block_onset_t
    resp2_b7_t <- dt_valid$onset_resp2[dt_valid$resp2_btn == 7] + dt_valid$resp2_t_corr[dt_valid$resp2_btn == 7] - block_onset_t
    resp2_b8_t <- dt_valid$onset_resp2[dt_valid$resp2_btn == 8] + dt_valid$resp2_t_corr[dt_valid$resp2_btn == 8] - block_onset_t
    
    write_onset(resp2_b5_t,f_set)
    write_onset(resp2_b6_t,f_set)
    write_onset(resp2_b7_t,f_set)
    write_onset(resp2_b8_t,f_set)
    
    # ITI onset (valid trials)
    ITI_valid_t <- dt_valid$onset_ITI - block_onset_t
    
    write_onset(ITI_valid_t,f_set)
    
    # Pre-stimulus interval (trial onset - 7 s)
    pre_trial_interval <- 7
    
    pre_CR_t <- dt_valid$mri_trigger[dt_valid$stim_type == 0 & dt_valid$resp1 == 0] - block_onset_t - pre_trial_interval
    pre_CR_conf_t <- dt_valid$mri_trigger[dt_valid$stim_type == 0 & dt_valid$resp1 == 0  & dt_valid$resp2 >= 3] - block_onset_t - pre_trial_interval
    
    pre_FA_t <- dt_valid$mri_trigger[dt_valid$stim_type == 0 & dt_valid$resp1 == 1] - block_onset_t - pre_trial_interval
    pre_FA_conf_t <- dt_valid$mri_trigger[dt_valid$stim_type == 0 & dt_valid$resp1 == 1  & dt_valid$resp2 >= 3] - block_onset_t - pre_trial_interval
    
    pre_near_miss_conf_t <- dt_valid$mri_trigger[dt_valid$stim_type == 1 & dt_valid$resp1 == 0  & dt_valid$resp2 >= 3] - block_onset_t - pre_trial_interval
    pre_near_hit_conf_t <- dt_valid$mri_trigger[dt_valid$stim_type == 1 & dt_valid$resp1 == 1  & dt_valid$resp2 >= 3] - block_onset_t - pre_trial_interval
    
    pre_supra_hit_conf_t <- dt_valid$mri_trigger[dt_valid$stim_type == 2 & dt_valid$resp1 == 1  & dt_valid$resp2 >= 3] - block_onset_t - pre_trial_interval
    
    write_onset(pre_CR_t,f_set)
    write_onset(pre_CR_conf_t,f_set)
    
    write_onset(pre_FA_t,f_set)
    write_onset(pre_FA_conf_t,f_set)
    
    write_onset(pre_near_miss_conf_t,f_set)
    write_onset(pre_near_hit_conf_t,f_set)
    
    write_onset(pre_supra_hit_conf_t,f_set)
    
  } # block loop
  
} # participant loop


}
