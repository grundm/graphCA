
# hit, miss, correct rejection, false alarm, missed yes/no response
colmap <- c('lightgreen','salmon', 'lightblue', 'red', 'lightgrey')
colmap <- c('lightgreen','lightsalmon', 'lightcyan', 'red', 'lightgrey')

dt$trial_col <- NA

dt$trial_col[dt$resp_filter == 1 & dt$stim_type==1 & dt$resp1==1] <- colmap[1] # hit
dt$trial_col[dt$resp_filter == 1 & dt$stim_type==1 & dt$resp1==0] <- colmap[2] # miss
dt$trial_col[dt$resp_filter == 1 & dt$stim_type==0 & dt$resp1==0] <- colmap[3] # CR
dt$trial_col[dt$resp_filter == 1 & dt$stim_type==0 & dt$resp1==1] <- colmap[4] # FA
dt$trial_col[dt$resp_filter == 0] <- NA # no response

barplot(as.numeric(!is.na(dt$trial_col[dt$ID==1 & dt$block==3])), border = NA, space = .1, col = dt$trial_col[dt$ID==1 & dt$block==1])

par(mfrow=(c(nrow(dID1),4)))
par(mfrow=c(6,4),
    oma = c(5,2,0,0) + 0.1,
    mar = c(0,0,1,1) + 0.1)

#for (ID in dID1$ID) {
for (ID in c(1,4,5,8,10,11)) {
  for (b in 1:4) {
    print(ID)
    print(b)
    
    if (sum(dt$block[dt$ID==ID]==b, na.rm = T)!=0 & db$block_filter[db$ID==ID & db$block==b]==1) {
      
      test <- sherman.unif.test(dt$resp1[dt$ID==ID & dt$block==b & dt$stim_type==1])
      
      print(test$statistic)
      
      barplot(as.numeric(!is.na(dt$trial_col[dt$ID==ID & dt$block==b])),
              col = dt$trial_col[dt$ID==ID & dt$block==b],
              border = NA,
              space = .1,
              axes = F)
      title(main = paste(ID, ' #', b, sep=''))
    } else {
      barplot(1:40,
              col = NA,
              border = NA,
              space = .1,
              axes = FALSE)
      title(main = paste(ID, ' #', b, sep=''))
    }
  }
}





t.test(db$near_yes[db$block==2],db$near_yes[db$block==4],paired=T)

barplot(dt$resp1[dt$ID==1 & dt$block==1 & dt$stim_type==1], border = NA, space = .1, col = 'lightgreen') # hit
barplot(dt$resp1[dt$ID==1 & dt$block==1 & dt$stim_type==1]==0, border = NA, col = 'red') # miss
barplot(dt$resp1[dt$ID==1 & dt$block==1 & dt$stim_type==0]==0, border = NA, col = 'red') # CR

barplot(dt$resp1[dt$ID==1 & dt$block==1 & dt$stim_type==1], border = NA, space = .1, col = c('lightgreen','red','green')) # hit

db$near_hit_trial_median[db$ID==1 & db$block==1]


# Detection rate across blocks --------------------------------------------

par(mfrow=(c(1,1)))


# SETTINGS ----------------------------------------------------------------

# Create colormap
# http://colorbrewer2.org/#type=qualitative&scheme=Set3&n=4
colmap <- c(rgb(141,211,199, maxColorValue=255),
            rgb(255,255,179, maxColorValue=255),
            rgb(190,186,218, maxColorValue=255),
            rgb(251,128,114, maxColorValue=255))


# PLOT DETECTION ----------------------------------------------------------

# Plot settings
par(cex.main = 2.4,
    cex.lab = 2.0,
    cex.axis = 1.8,
    #mar = c(4.5, 5.5, 4, 1),
    mar = c(4.1, 5.1, 4.1, 2.1),
    yaxs = 'i',
    xaxs = 'i',
    yaxt = 'n',
    xaxt = 'n',
    bty = 'o')


# Near hit x block --------------------------------------------------------

# boxplot(db$near_yes[db$block==1 & db$ID %in% dID1$ID & db$block_filter==1],
#         db$near_yes[db$block==2 & db$ID %in% dID1$ID & db$block_filter==1],
#         db$near_yes[db$block==3 & db$ID %in% dID1$ID & db$block_filter==1],
#         db$near_yes[db$block==4 & db$ID %in% dID1$ID & db$block_filter==1],
#         col=colmap[4],
#         range = 1.5,
#         ylim = c(0,1),
#         whisklty = 1,
#         outpch = 21,
#         outbg = 'black',
#         outcex = .9,
#         xlab = 'Block')
# 
# # Set title
# title(main = 'Near hit rate x block')
# 
# title(ylab = 'P(yes)', line = 3.6)


# Near conf x block -------------------------------------------------------

boxplot(db$near_conf[db$block==1 & db$ID %in% dID1$ID & db$block_filter==1],
        db$near_conf[db$block==2 & db$ID %in% dID1$ID & db$block_filter==1],
        db$near_conf[db$block==3 & db$ID %in% dID1$ID & db$block_filter==1],
        db$near_conf[db$block==4 & db$ID %in% dID1$ID & db$block_filter==1],
        col=colmap[4],
        range = 1.5,
        ylim = c(1,4),
        whisklty = 1,
        outpch = 21,
        outbg = 'black',
        outcex = .9,
        xlab = 'Block')

# Set title
title(main = 'Confidence x block')

title(ylab = 'Mean confidence', line = 3.6)

# Null FA x block --------------------------------------------------------

boxplot(db$null_yes[db$block==1 & db$ID %in% dID1$ID & db$block_filter==1],
        db$null_yes[db$block==2 & db$ID %in% dID1$ID & db$block_filter==1],
        db$null_yes[db$block==3 & db$ID %in% dID1$ID & db$block_filter==1],
        db$null_yes[db$block==4 & db$ID %in% dID1$ID & db$block_filter==1],
        col=colmap[1],
        range = 1.5,
        ylim = c(0,1),
        whisklty = 1,
        outpch = 21,
        outbg = 'black',
        outcex = .9,
        xlab = 'Block')

# Set title
title(main = 'False alarm rate x block')

title(ylab = 'P(yes)', line = 3.6)

# Null conf x block -------------------------------------------------------

boxplot(db$null_conf[db$block==1 & db$ID %in% dID1$ID & db$block_filter==1],
        db$null_conf[db$block==2 & db$ID %in% dID1$ID & db$block_filter==1],
        db$null_conf[db$block==3 & db$ID %in% dID1$ID & db$block_filter==1],
        db$null_conf[db$block==4 & db$ID %in% dID1$ID & db$block_filter==1],
        col=colmap[1],
        range = 1.5,
        ylim = c(1,4),
        whisklty = 1,
        outpch = 21,
        outbg = 'black',
        outcex = .9,
        xlab = 'Block')

# Set title
title(main = 'Confidence x block')

title(ylab = 'Mean confidence', line = 3.6)

# Activitate axes
par(xaxt = 's')
par(yaxt = 's')

axis(side = 2,
     at = seq(0, 1, .2),
     las = 1)

axis(side = 2,
     at = seq(1, 4, 1),
     las = 1)

axis(side = 1,
     at = 1:4,
     labels = 1:4,
     mgp = c(1, 1, 0))


# ANOVA - Near hit rate x block -------------------------------------------

library("ez")

HR = aggregate(near_yes ~ ID*block, subset(db, db$ID %in% dID1$ID & db$block_filter == 1), FUN=mean)

HR$ID <- as.factor(HR$ID)
HR$block <- as.factor(HR$block)

# Call to ANOVA wrapper
output_anova = ezANOVA(data = HR,       # dataframe containing all relevant variables, see below
                       dv = near_yes,        # dependent variable: detection (yes/no)
                       wid = ID,          # array with the participant ID within the dataframe
                       within= .(block),   # specify the names of within-subject factors
                       type = 3,          # sum-of-squares-type, should be '3' in your case, but check function help to be sure
                       detailed = TRUE,   # some output options
                       return_aov = TRUE
)

print(output_anova)

library(lme4)

fit <- lmer(near_yes ~ block + (1|ID), HR)
summary(fit)
anova(fit)

fit_null <- lmer(near_yes ~ 1 + (1|ID), HR, REML = FALSE)
fit_ml <- lmer(near_yes ~ block + (1|ID), HR, REML = FALSE)
anova(fit_null,fit_ml)

summary(fit_null)


# Near confidence x block

HR = aggregate(near_conf ~ ID*block, subset(db, db$ID %in% dID1$ID & db$block_filter == 1), FUN=mean)

HR$ID <- as.factor(HR$ID)

fit_null <- lmer(near_conf ~ 1 + (1|ID), HR, REML = FALSE)
fit_ml <- lmer(near_conf ~ block + (1|ID), HR, REML = FALSE)
anova(fit_null,fit_ml)

# FAR x block

HR = aggregate(null_yes ~ ID*block, subset(db, db$ID %in% dID1$ID & db$block_filter == 1), FUN=mean)

HR$ID <- as.factor(HR$ID)

fit_null <- lmer(null_yes ~ 1 + (1|ID), HR, REML = FALSE)
fit_ml <- lmer(null_yes ~ block + (1|ID), HR, REML = FALSE)
anova(fit_null,fit_ml)

# Null conf x block

HR = aggregate(null_conf ~ ID*block, subset(db, db$ID %in% dID1$ID & db$block_filter == 1), FUN=mean)

HR$ID <- as.factor(HR$ID)

fit_null <- lmer(null_conf ~ 1 + (1|ID), HR, REML = FALSE)
fit_ml <- lmer(null_conf ~ block + (1|ID), HR, REML = FALSE)
anova(fit_null,fit_ml)


# t-Tests -----------------------------------------------------------------

combinations <- combn(4,2)

p_val <- numeric(0)

for (c in 1:choose(4,2)) {
  
  b1=combinations[1,c]
  b2=combinations[2,c]
  
  ID_block1 <- db$ID[db$block==b1 & db$ID %in% dID1$ID & db$block_filter==1]
  ID_block2 <- db$ID[db$block==b2 & db$ID %in% dID1$ID & db$block_filter==1]
  
  ID_both <- ID_block1[ID_block1 %in% ID_block2]
  
  t_res <- t.test(db$null_conf[db$block==b1 & db$ID %in% ID_both & db$block_filter==1],
                  db$null_conf[db$block==b2 & db$ID %in% ID_both & db$block_filter==1],
                  paired = TRUE)
  
  print(t_res)
  
  p_val[c] <- t_res$p.value
  
}

p_fdr <- p.adjust(p_val,'fdr')