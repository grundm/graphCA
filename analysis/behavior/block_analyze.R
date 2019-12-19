function (d) {
# input "d" <- output by "trial_filter.R"
  
# FILTER SETTINGS ----------------------------------------------------------------

# Number of trials
null_n_min <-	4
near_n_min <-	17

# Detection
null_max <- 1#0.3
near_min <-	0#0.25
near_max <- 1.0#0.75

margin_hit_FA = 0.05

#  Median trial of near hits
near_hit_trial_min <- 0 #12.5 # exception ">" not ">=" as usual
near_hit_trial_max <- 40 #27.5

# Codes to select trials properly
null_code <- 0
near_code <- 1
supra_code <- 2

miss_code <- 0
hit_code <- 1
conf_min <- 3
unconf_max <- 2


# DETECTION & CONFIDENCE MEASURES ------------------------------------------------------

db <- data.frame(ID = integer(0),
                 block = integer(0),
                 null_intensity = numeric(0),
                 null_yes = numeric(0),
                 null_conf = numeric(0),
                 null_n = integer(0),
                 null_conf_n = numeric(0),
                 null_conf_yes = numeric(0),
                 null_unconf_n = numeric(0),
                 null_unconf_yes = numeric(0),
                 null_rt1 = numeric(0),
                 null_rt2 = numeric(0),
                 null_no_conf = numeric(0),
                 null_yes_conf = numeric(0),
                 null_no_conf_conf = numeric(0),
                 null_no_conf_n = numeric(0),
                 null_no_n = numeric(0),
                 null_no_conf1 = numeric(0),
                 null_no_conf2 = numeric(0),
                 null_no_conf3 = numeric(0),
                 null_no_conf4 = numeric(0),
                 null_yes_conf1 = numeric(0),
                 null_yes_conf2 = numeric(0),
                 null_yes_conf3 = numeric(0),
                 null_yes_conf4 = numeric(0),
                 near_intensity = numeric(0),
                 near_yes = numeric(0),
                 near_conf = numeric(0),
                 near_n = integer(0),
                 near_conf_n = numeric(0),
                 near_conf_yes = numeric(0),
                 near_unconf_n = numeric(0),
                 near_unconf_yes = numeric(0),
                 near_rt1 = numeric(0),
                 near_rt2 = numeric(0),
                 near_miss_conf = numeric(0),
                 near_hit_conf = numeric(0),
                 near_hit_trial_median = numeric(0),
                 near_miss_n = numeric(0),
                 near_hit_n = numeric(0),
                 near_miss_rt1 = numeric(0),
                 near_hit_rt1 = numeric(0),
                 near_miss_rt2 = numeric(0),
                 near_hit_rt2 = numeric(0),
                 near_miss_conf_n = numeric(0),
                 near_miss_unconf_n = numeric(0),
                 near_hit_conf_n = numeric(0),
                 near_hit_unconf_n = numeric(0),
                 near_miss_conf_rt1 = numeric(0),
                 near_miss_unconf_rt1 = numeric(0),
                 near_hit_conf_rt1 = numeric(0),
                 near_hit_unconf_rt1 = numeric(0),
                 near_miss_conf_rt2 = numeric(0),
                 near_miss_unconf_rt2 = numeric(0),
                 near_hit_conf_rt2 = numeric(0),
                 near_hit_unconf_rt2 = numeric(0),
                 near_miss_conf_conf = numeric(0),
                 near_hit_conf_conf = numeric(0),
                 near_miss_unconf_conf = numeric(0),
                 near_hit_unconf_conf = numeric(0),
                 near_miss_conf1 = numeric(0),
                 near_miss_conf2 = numeric(0),
                 near_miss_conf3 = numeric(0),
                 near_miss_conf4 = numeric(0),
                 near_hit_conf1 = numeric(0),
                 near_hit_conf2 = numeric(0),
                 near_hit_conf3 = numeric(0),
                 near_hit_conf4 = numeric(0),
                 supra_intensity = numeric(0),
                 supra_yes = numeric(0),
                 supra_conf = numeric(0),
                 supra_n = integer(0),
                 supra_conf_n = numeric(0),
                 supra_conf_yes = numeric(0),
                 supra_unconf_n = numeric(0),
                 supra_unconf_yes = numeric(0),
                 supra_rt1 = numeric(0),
                 supra_rt2 = numeric(0),
                 supra_no_conf = numeric(0),
                 supra_yes_conf = numeric(0),
                 supra_yes_conf_conf = numeric(0),
                 supra_yes_conf_n = numeric(0),
                 supra_yes_n = numeric(0),
                 supra_yes_conf1 = numeric(0),
                 supra_yes_conf2 = numeric(0),
                 supra_yes_conf3 = numeric(0),
                 supra_yes_conf4 = numeric(0)
                 )  
  
# Loop participants
for (i in unique(d$ID)) {
  # Loop blocks
  for (j in unique(d$block) ) {
    
    # Filter for ID, block and valid responses (see "trial_filter.R")
    d_sub <- subset(d, ID==i & block==j & resp_filter)
    
    results <- c(i,j)
    
    # Loop conditions
    for (cond in sort(unique(d$stim_type)) ) {
      
      # Filter for condition (stimulus type)
      d_sub_cond <- subset(d_sub, stim_type==cond)
      
      # Detection rate and number of trials per condition
      results <- append(results, c(mean(d_sub_cond$intensity),
                                   mean(d_sub_cond$resp1),
                                   mean(d_sub_cond$resp2),
                                   length(d_sub_cond$resp1),
                                   length(d_sub_cond$resp1[d_sub_cond$resp2 >= conf_min]),
                                   mean(d_sub_cond$resp1[d_sub_cond$resp2 >= conf_min]),
                                   length(d_sub_cond$resp1[d_sub_cond$resp2 <= unconf_max]),
                                   mean(d_sub_cond$resp1[d_sub_cond$resp2 <= unconf_max]),
                                   mean(d_sub_cond$resp1_t_corr),
                                   mean(d_sub_cond$resp2_t_corr) ) )
      
      if (cond != near_code) {
        results <- append(results, c(mean( d_sub_cond$resp2[d_sub_cond$resp1==miss_code] ),
                                     mean( d_sub_cond$resp2[d_sub_cond$resp1==hit_code] ) ))
      }
      
      if (cond == null_code) {
        results <- append(results, c(mean( d_sub_cond$resp2[d_sub_cond$resp1==miss_code & d_sub_cond$resp2 >= conf_min]),
                                     length( d_sub_cond$resp1[d_sub_cond$resp1==miss_code & d_sub_cond$resp2 >= conf_min]),
                                     length( d_sub_cond$resp1[d_sub_cond$resp1==miss_code]),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 1),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 2),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 3),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 4),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 1),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 2),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 3),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 4)
                                     
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 1)/length( d_sub_cond$resp2[d_sub_cond$resp1==miss_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 2)/length( d_sub_cond$resp2[d_sub_cond$resp1==miss_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 3)/length( d_sub_cond$resp2[d_sub_cond$resp1==miss_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 4)/length( d_sub_cond$resp2[d_sub_cond$resp1==miss_code])
                                     )
                          )
      }
      
      if (cond == supra_code) {
        results <- append(results, c(mean( d_sub_cond$resp2[d_sub_cond$resp1==hit_code & d_sub_cond$resp2 >= conf_min]),
                                     length( d_sub_cond$resp1[d_sub_cond$resp1==hit_code & d_sub_cond$resp2 >= conf_min]),
                                     length( d_sub_cond$resp1[d_sub_cond$resp1==hit_code]),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 1),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 2),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 3),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 4)
                                     
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 1)/length( d_sub_cond$resp2[d_sub_cond$resp1==hit_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 2)/length( d_sub_cond$resp2[d_sub_cond$resp1==hit_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 3)/length( d_sub_cond$resp2[d_sub_cond$resp1==hit_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 4)/length( d_sub_cond$resp2[d_sub_cond$resp1==hit_code])
                                     )
                          )
      }
      
      # Confidence for near hits and misses
      # Median trial number for near trials
      if (cond == near_code) {
        results <- append(results, c(mean( d_sub_cond$resp2[d_sub_cond$resp1==miss_code] ),
                                     mean( d_sub_cond$resp2[d_sub_cond$resp1==hit_code] ),
                                     median( d_sub_cond$trial[d_sub_cond$resp1==hit_code] ),
                                     length( d_sub_cond$resp1[d_sub_cond$resp1==miss_code]),
                                     length( d_sub_cond$resp1[d_sub_cond$resp1==hit_code]),
                                     mean( d_sub_cond$resp1_t_corr[d_sub_cond$resp1==miss_code] ),
                                     mean( d_sub_cond$resp1_t_corr[d_sub_cond$resp1==hit_code] ),
                                     mean( d_sub_cond$resp2_t_corr[d_sub_cond$resp1==miss_code] ),
                                     mean( d_sub_cond$resp2_t_corr[d_sub_cond$resp1==hit_code] ),
                                     length( d_sub_cond$resp1[d_sub_cond$resp1==miss_code & d_sub_cond$resp2 >= conf_min]),
                                     length( d_sub_cond$resp1[d_sub_cond$resp1==miss_code & d_sub_cond$resp2 <= unconf_max]),
                                     length( d_sub_cond$resp1[d_sub_cond$resp1==hit_code & d_sub_cond$resp2 >= conf_min]),
                                     length( d_sub_cond$resp1[d_sub_cond$resp1==hit_code & d_sub_cond$resp2 <= unconf_max]),
                                     mean( d_sub_cond$resp1_t_corr[d_sub_cond$resp1==miss_code & d_sub_cond$resp2 >= conf_min]),
                                     mean( d_sub_cond$resp1_t_corr[d_sub_cond$resp1==miss_code & d_sub_cond$resp2 <= unconf_max]),
                                     mean( d_sub_cond$resp1_t_corr[d_sub_cond$resp1==hit_code & d_sub_cond$resp2 >= conf_min]),
                                     mean( d_sub_cond$resp1_t_corr[d_sub_cond$resp1==hit_code & d_sub_cond$resp2 <= unconf_max]),
                                     mean( d_sub_cond$resp2_t_corr[d_sub_cond$resp1==miss_code & d_sub_cond$resp2 >= conf_min]),
                                     mean( d_sub_cond$resp2_t_corr[d_sub_cond$resp1==miss_code & d_sub_cond$resp2 <= unconf_max]),
                                     mean( d_sub_cond$resp2_t_corr[d_sub_cond$resp1==hit_code & d_sub_cond$resp2 >= conf_min]),
                                     mean( d_sub_cond$resp2_t_corr[d_sub_cond$resp1==hit_code & d_sub_cond$resp2 <= unconf_max]),
                                     mean( d_sub_cond$resp2[d_sub_cond$resp1==miss_code & d_sub_cond$resp2 >= conf_min]),
                                     mean( d_sub_cond$resp2[d_sub_cond$resp1==hit_code & d_sub_cond$resp2 >= conf_min]),
                                     mean( d_sub_cond$resp2[d_sub_cond$resp1==miss_code & d_sub_cond$resp2 <= unconf_max]),
                                     mean( d_sub_cond$resp2[d_sub_cond$resp1==hit_code & d_sub_cond$resp2 <= unconf_max]),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 1),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 2),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 3),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 4),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 1),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 2),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 3),
                                     sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 4)
                                     
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 1)/length( d_sub_cond$resp2[d_sub_cond$resp1==miss_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 2)/length( d_sub_cond$resp2[d_sub_cond$resp1==miss_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 3)/length( d_sub_cond$resp2[d_sub_cond$resp1==miss_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==miss_code] == 4)/length( d_sub_cond$resp2[d_sub_cond$resp1==miss_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 1)/length( d_sub_cond$resp2[d_sub_cond$resp1==hit_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 2)/length( d_sub_cond$resp2[d_sub_cond$resp1==hit_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 3)/length( d_sub_cond$resp2[d_sub_cond$resp1==hit_code]),
                                     # sum(d_sub_cond$resp2[d_sub_cond$resp1==hit_code] == 4)/length( d_sub_cond$resp2[d_sub_cond$resp1==hit_code])
                                     )
                          )

      }
    }
    
    db[nrow(db)+1,] <- results
  }
}

# Confidence difference between near misses and hits
db$near_diff_conf <- db$near_miss_conf - db$near_hit_conf


# BLOCK FILTER ------------------------------------------------------------

# Number of trials filter
db$n_filter <- as.integer(db$null_n >= null_n_min & db$near_n >= near_n_min)
# -> min(db$supra_n[db$n_filter==1]): 3

# Detection filter
db$null_yes_filter <- as.integer(db$null_yes <= null_max)
db$near_yes_filter <- as.integer(db$near_yes >= near_min & db$near_yes <= near_max)

db$yes_filter <- as.integer(db$null_yes_filter & db$near_yes_filter)

# Median near hit filter
db$near_hit_trial_median_filter <- as.integer(db$near_hit_trial_median > near_hit_trial_min & db$near_hit_trial_median <= near_hit_trial_max)

# More hit than false alarms?
db$HR_larger_FAR_filter <- as.integer((db$near_yes-db$null_yes)>margin_hit_FA)

# Combine filter
#db$block_filter <- as.integer(db$n_filter & db$yes_filter & db$near_hit_trial_median_filter)
db$block_filter <- as.integer(db$n_filter & db$yes_filter & db$HR_larger_FAR_filter)

return(db)

}
