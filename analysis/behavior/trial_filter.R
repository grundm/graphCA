function(d) {
# Preprocessing on trial level
  

# FILTER SETTINGS ---------------------------------------------------------

# Response times
resp1_min <- 0.1
resp1_max <- 1.5
resp2_max <- resp1_max

# Response buttons
resp1_btn <- c(6,7)
resp2_btn <- c(5,6,7,8)

  
# TRIAL DURATION ----------------------------------------------------------

d$trial_t <- ifelse((d$trial < max(d$trial)), tail(d$mri_trigger,-1) - head(d$mri_trigger,-1), 0)


# STIMULUS ONSET ----------------------------------------------------------

for (i in unique(d$ID)) {
  for (j in unique(d$block[d$ID==i])) {
    d$stim_onset[d$ID==i & d$block==j] <- d$mri_trigger[d$ID==i & d$block==j] + d$t_mri_stim_onset[d$ID==i & d$block==j]/1000 - d$mri_trigger[d$ID==i & d$block==j][1]
  }
}

# CORRECT RESPONSE TIMES --------------------------------------------------

# For ID01 & ID02 response times in ms not s
d$resp1_t[d$ID<=2] <- d$resp1_t[d$ID<=2]/1000
d$resp2_t[d$ID<=2] <- d$resp2_t[d$ID<=2]/1000

# Correct for delay in scanner environment

# Settings
resp_btn <- c(5,6,7,8)
#btn_delays <- c(.0488, .0490, .0436, .0434, .0422, .0422, .0428, .0428)
btn_delays <- c(.0422, .0422, .0428, .0428)

# only adjusts by delay if one of the defined buttons was pressed (resp_btn)
# adjusted response times contain for instance cases where parallel port failed (resp btn = 9)
d$resp1_t_corr <- d$resp1_t - sapply(match(d$resp1_btn, resp_btn, 0), function (x) ifelse(x, btn_delays[x], 0))
d$resp2_t_corr <- d$resp2_t - sapply(match(d$resp2_btn, resp_btn, 0), function (x) ifelse(x, btn_delays[x], 0))


# FILTER ----------------------------------------------------

# Response time filter
d$resp_t_filter <- as.integer(d$resp1_t_corr > resp1_min & d$resp1_t_corr < resp1_max & d$resp2_t_corr < resp2_max)

# Response button filter
d$resp_btn_filter <- as.integer(match(d$resp1_btn, resp1_btn, 0) & match(d$resp2_btn, resp2_btn, 0))

# Combine response time & button filter
d$resp_filter <- as.integer(d$resp_t_filter & d$resp_btn_filter)


return(d)

}
