function (db) {
# input "db" <- output by "block_analyze.R"

# FILTER SETTINGS ---------------------------------------------------------

# Number of blocks 
block_min <- 3
near_yes_min <- 0.20
near_yes_max <- 0.80


# AVERAGE BLOCKS PER PARTICIPANT ------------------------------------------

# Loop participants
for (i in unique(db$ID)) {
    
    db_sub <- subset(db, ID==i & block_filter)
    
    block_num <- nrow(db_sub)
    
    if (block_num >= block_min & mean(db_sub$near_yes) >= near_yes_min & mean(db_sub$near_yes) <= near_yes_max) {
      
      valid_blocks <- as.integer(paste(sort(db_sub$block), collapse = ''))
      
      results <- c(ID=i, colMeans(db_sub[,3:(ncol(db_sub)-6)], na.rm = TRUE), block_num=block_num, valid_blocks=valid_blocks)
    
      if ( tryCatch(is.data.frame(dID1), error=function(cond) FALSE) ) {
        
        dID1[nrow(dID1)+1,] <- results
        
      } else {
        dID1 <- data.frame(t(results))
      }
      
    }
}

return(dID1)

}
