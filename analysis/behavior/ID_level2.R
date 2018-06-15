function (db) {
# input "db" <- output by "block_analyze.R"

# ALTERNATIVE TO "ID_level.R"

# Conceptually it pools the blocks together. Instead of a requested interval
# for the near-threshold detection rate (e.g., 25-75%) and the median hit trial 
# number per block, it selects all blocks that have "enough" trials without and
# with near-threshold stimulation, and the false alarm rate below a predefined 
# threshold (see "block_analyze.R").
# 
# Over the filtered blocks it goes for a minimum number of blocks and a minimum of 
# near-threshold hits & misses.
  
# sum(dID$near_n*dID$block_num)
# [1] 1397
  
# > sum(dID_new$near_n_sum)
# [1] 2590
# with filtering for minimum hits & misses
# sum(dID_new$near_n_sum)
# [1] 2297


# FILTER SETTINGS ---------------------------------------------------------

# Number of blocks 
block_min <- 3

# Number of hits and misses over all blocks
near_yes_n_min <- 25
near_no_n_min <- 25


# AVERAGE BLOCKS PER PARTICIPANT ------------------------------------------

# Loop participants
for (i in unique(db$ID)) {
  
  ### FILTER BLOCKS ###
  # Filter for number of trials without and with near-threshold stimulation (n_filter)
  # and false alarms below predefined threshold (null_yes_filter, for details "block_analyze.R")
  db_sub <- subset(db, ID==i & n_filter & null_yes_filter)
  
  ### BLOCK MEASURES ###
  block_num <- nrow(db_sub)
  
  if (block_num) {
    
    valid_blocks <- as.integer(paste(sort(db_sub$block), collapse = ''))
  
    near_intensity <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$near_intensity[db_sub$block==x], NA),i)
  
    near_yes <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$near_yes[db_sub$block==x], NA),i)
    
    near_n <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$near_n[db_sub$block==x], NA),i)
    
    near_yes_n <- sum(near_n * near_yes, na.rm = TRUE)
    near_no_n <- sum(near_n * (1-near_yes), na.rm = TRUE)
    
    near_conf_n <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$near_conf_n[db_sub$block==x], NA),i)
    near_conf_yes <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$near_conf_yes[db_sub$block==x], NA),i)
    near_unconf_n <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$near_unconf_n[db_sub$block==x], NA),i)
    near_unconf_yes <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$near_unconf_yes[db_sub$block==x], NA),i)
    
    # Catch trials
    null_yes <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$null_yes[db_sub$block==x], NA),i)
    
    null_n <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$null_n[db_sub$block==x], NA),i)
    
    null_yes_n <- sum(null_n * null_yes, na.rm = TRUE)
    null_no_n <- sum(null_n * (1-null_yes), na.rm = TRUE)
    
    null_conf_n <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$null_conf_n[db_sub$block==x], NA),i)
    null_conf_yes <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$null_conf_yes[db_sub$block==x], NA),i)
    null_unconf_n <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$null_unconf_n[db_sub$block==x], NA),i)
    null_unconf_yes <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$null_unconf_yes[db_sub$block==x], NA),i)
    
    # Supra trials
    supra_yes <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$supra_yes[db_sub$block==x], NA),i)
    
    supra_n <- sapply(c(1:4), function (x,i) ifelse(any(db_sub$block==x), db_sub$supra_n[db_sub$block==x], NA),i)
    
    supra_yes_n <- sum(supra_n * supra_yes, na.rm = TRUE)
    supra_no_n <- sum(supra_n * (1-supra_yes), na.rm = TRUE)
  
    block_d <- c(block_num=block_num,
                 valid_blocks=valid_blocks,
                 near_intensity=near_intensity,
                 near_yes=near_yes,
                 near_n=near_n,
                 near_n_sum=sum(db_sub$near_n),
                 near_yes_n=near_yes_n,
                 near_no_n=near_no_n,
                 near_n_diff=near_yes_n-near_no_n,
                 near_conf_n=near_conf_n,
                 near_conf_yes=near_conf_yes,
                 near_unconf_n=near_unconf_n,
                 near_unconf_yes=near_unconf_yes,
                 null_yes=null_yes,
                 null_n=null_n,
                 null_n_sum=sum(db_sub$null_n),
                 null_yes_n=null_yes_n,
                 null_no_n=null_no_n,
                 null_conf_n=null_conf_n,
                 null_conf_yes=null_conf_yes,
                 null_unconf_n=null_unconf_n,
                 null_unconf_yes=null_unconf_yes,
                 supra_yes=supra_yes,
                 supra_n=supra_n,
                 supra_n_sum=sum(db_sub$supra_n),
                 supra_yes_n=supra_yes_n,
                 supra_no_n=supra_no_n)
    
    ### CREATE DATA FRAME ###
    # Start after ID & block ("3") and ignore filter ("-6")
    results <- c(ID=i, colMeans(db_sub[,3:(ncol(db_sub)-6)], na.rm = TRUE), block_d)
    
    if ( tryCatch(is.data.frame(dID2), error=function(cond) FALSE) ) {
      
      dID2[nrow(dID2)+1,] <- results
      
    } else {
      dID2 <- data.frame(t(results))
    }
    
  } # if - valid blocks
}

  ### FILTER PARTICIPANTS ###
  #dID_sub <- subset(dID2, block_num >= block_min & near_yes_n >= near_yes_n_min & near_no_n >= near_no_n_min)
  dID_sub <- subset(dID2, near_yes_n >= near_yes_n_min & near_no_n >= near_no_n_min)

  return(dID_sub)
  #return(dID2)
  
}
