# DATA - ALL --------------------------------------------------------------------

# Mean yes response rate
conf_resp <- data.frame(CR_conf = dID_new2$null_no_conf,
                        near_miss_conf = dID_new2$near_miss_conf,
                        near_hit_conf = dID_new2$near_hit_conf,
                        supra_hit_conf = dID_new2$supra_yes_conf)

# Number of trials
trial_n <- data.frame(null_no_n = dID_new2$null_no_n,
                      near_no_n = dID_new2$near_no_n,
                      near_yes_n = dID_new2$near_yes_n,
                      supra_yes_n = dID_new2$supra_yes_n)

# Title
main_title <- substitute(paste('Confidence (N = ', x, ')', sep = ''), list(x=nrow(conf_resp)))
# Did not manage an italic 'n' yet. Tried substitute and expression.

# Condition labels
#cond_lab <- c('CR', 'Near-miss', 'Near-hit', 'Supra-hit')
cond_lab <- c('CR', 'Near-miss', 'Near-hit', 'Supra-hit')


# DATA - CONFIDENT --------------------------------------------------------

# Mean yes response rate
conf_resp <- data.frame(CR_conf = dID_new2$null_no_conf_conf,
                        near_miss_conf = dID_new2$near_miss_conf_conf,
                        near_hit_conf = dID_new2$near_hit_conf_conf,
                        supra_hit_conf = dID_new2$supra_yes_conf_conf)

# Number of trials
trial_n <- data.frame(null_no_n = dID_new2$null_no_conf_n,
                      near_no_n = dID_new2$near_miss_conf_n,
                      near_yes_n = dID_new2$near_hit_conf_n,
                      supra_yes_n = dID_new2$supra_yes_conf_n)

# Title
main_title <- substitute(paste('Confidence - Confident trials (N = ', x, ')', sep = ''), list(x=nrow(conf_resp)))
# Did not manage an italic 'n' yet. Tried substitute and expression.

# Condition labels
#cond_lab <- c('CR_conf', 'Near_miss_conf', 'Near_hit_conf', 'Supra_hit_conf')
cond_lab <- c('CR', 'Near_miss', 'Near_hit', 'Supra_hit')

# SETTINGS ----------------------------------------------------------------

# Y-axis label
y_axis_label <- 'Mean confidence rating'

# Category labels (x-axis)
x_labels <- c(paste(cond_lab[1], '\n(n~', round(mean(trial_n$null_no_n)), ')', sep = ''),
              paste(cond_lab[2], '\n(n~', round(mean(trial_n$near_no_n)), ')', sep = ''),
              paste(cond_lab[3], '\n(n~', round(mean(trial_n$near_yes_n)), ')', sep = ''),
              paste(cond_lab[4], '\n(n~', round(mean(trial_n$supra_yes_n)), ')', sep = ''))

# Create colormap
# http://colorbrewer2.org/#type=qualitative&scheme=Set3&n=4
colmap <- c(rgb(141,211,199, maxColorValue=255),
            rgb(190,186,218, maxColorValue=255),
            rgb(251,128,114, maxColorValue=255),
            rgb(255,255,179, maxColorValue=255))

# col <- matrix(c(27,158,119,
#                 117,112,179,
#                 217,95,2,
#                 255,255,179),
#               nrow = 4,
#               ncol = 3,
#               byrow = TRUE)
# 
# col <- col/255
# 
# colmap <- c(rgb(col[1,1], col[1,2], col[1,3], 0.5),
#              rgb(col[2,1], col[2,2], col[2,3], 0.5),
#              rgb(col[3,1], col[3,2], col[3,3], 0.5),
#             rgb(col[4,1], col[4,2], col[4,3], 0.5))

# T-test lines with p-value asteriks
colGrid <- rgb(0.25,0.25,0.25) # Also use for "rather unconfident" label
ttest_line <- 2
p_value_txt <- 1.8

# PLOT CONFIDENCE ---------------------------------------------------------

# Plot settings
par(cex.main = 2.4,
    cex.lab = 2.0,
    cex.axis = 1.8,
    mar = c(4.5, 5.5, 4, 1),
    yaxs = 'i',
    yaxt = 'n',
    xaxs = 'r',
    xaxt = 'n',
    bty = 'o')

conf_resp_norm <- (conf_resp - 1)/3

boxplot(conf_resp_norm,
        ylim = range(0:1),
        col = colmap,
        las = 1)

# Color unconfident area
rect(0, 0, 5, 0.5, col = "ivory2", border = 0)
#rect(0, 2.5, 5, 4, col = "floralwhite", border = 0)

boxplot(conf_resp_norm,
        ylim = range(0:1),
        col= colmap,
        las = 1,
        add = TRUE)

# Set title
title(main = main_title)

# Label y-axis
title(ylab = y_axis_label,
      line = 3.6)

par(xaxt = 's')
par(yaxt = 's')

axis(side = 2,
     at = seq(0, 1, .2),
     las = 1)

#seq(1, 4, 1),

axis(side = 1,
     at = 1:4,
     labels = x_labels,
     mgp = c(3, 3, 0))


# Scale labels
scl_lbl_txt <- 1.35
text(0.4,0.44,'\U2193 rather\nunconfident', pos = 4, col = colGrid, cex = 1.4)
#text(0.35,1.1,'unconfident', pos = 4, col = colGrid, cex = 1.4)


# ADD T-TEST INFORMATION --------------------------------------------------

# Legend - p-values
# * p < 0.05
# ** p < 0.01
# *** p < 0.001
text(x = 4.6,
     y = 0.15,
     labels = expression(paste('* ', italic(P), ' < 0.05', sep = '')),
     pos = 2,
     col = colGrid,
     cex = 1.4)

text(x = 4.6,
     y = 0.1,
     labels = expression(paste('** ', italic(P), ' < 0.01', sep = '')),
     pos = 2,
     col = colGrid,
     cex = 1.4)

text(x = 4.6,
     y = 0.05,
     labels = expression(paste('*** ', italic(P),' < 0.001', sep = '')),
     pos = 2,
     col = colGrid,
     cex = 1.4)

#substitute(paste('* ', italic(P), '< 0.05\n** ',italic(P),' < 0.01\n*** ',italic(P),' < 0.001', sep = '')),
#expression('* ', italic(P), '< 0.05\n** ',italic(P),' < 0.01\n*** ',italic(P),' < 0.001')

# Add lines and asteriks for p-values

#t.test(dID_new2$null_no_conf, dID_new2$near_miss_conf, paired = TRUE)
#t.test(conf_resp_norm$CR_conf, conf_resp_norm$near_miss_conf, paired = TRUE)
# p-value = 5.097e-06
lines(c(1,2),c(0.38,0.38), col = colGrid, lwd = ttest_line)
text(1.5,0.38,'***', pos = 1, col = colGrid, cex = p_value_txt)

#t.test(dID_new2$near_miss_conf, dID_new2$near_hit_conf, paired = TRUE)
#t.test(conf_resp_norm$near_miss_conf, conf_resp_norm$near_hit_conf, paired = TRUE)
# p-value = 0.00464
lines(c(2,3),c(0.27,0.27), col = colGrid, lwd = ttest_line)
text(2.5,0.27,'**', pos = 1, col = colGrid, cex = p_value_txt)

#t.test(dID_new2$near_hit_conf, dID_new2$supra_yes_conf, paired = TRUE)
# p-value = 2.377e-09
lines(c(3,4),c(0.25,0.25), col = colGrid, lwd = ttest_line)
text(3.5,0.25,'***', pos = 1, col = colGrid, cex = p_value_txt)

#t.test(dID_new2$null_no_conf, dID_new2$supra_yes_conf, paired = TRUE)
# p-value = 0.04253
lines(c(1,4),c(0.2,0.2), col = colGrid, lwd = ttest_line)
text(2.5,0.2,'*', pos = 1, col = colGrid, cex = p_value_txt)


# ADD T-TEST INFORMATION - CONFIDENT --------------------------------------------------

# Legend - p-values
# * p < 0.05
# ** p < 0.01
# *** p < 0.001
text(4.65,1.2,'* p < .05\n** p < .01\n*** p < .001',pos = 2, col = colGrid, cex = 1.4)

# Add lines and asteriks for p-values

#t.test(dID_new2$null_no_conf_conf, dID_new2$near_miss_conf_conf, paired = TRUE)
# p-value = 0.0004611
lines(c(1,2),c(3.05,3.05), col = colGrid, lwd = ttest_line)
text(1.5,3.05,'***', pos = 1, col = colGrid, cex = p_value_txt)

#t.test(dID_new2$near_miss_conf_conf, dID_new2$near_hit_conf_conf, paired = TRUE)
#t.test(conf_resp_norm$near_miss_conf, conf_resp_norm$near_hit_conf, paired = TRUE)
# p-value = 0.6107
#lines(c(2,3),c(3,3), col = colGrid, lwd = ttest_line)
#text(2.5,3,expression(paste(italic('p'), ' = .61')), pos = 1, col = colGrid, cex = p_value_txt)

#t.test(dID_new2$near_hit_conf_conf, dID_new2$supra_yes_conf_conf, paired = TRUE)
# p-value = 8.413e-09
lines(c(3,4),c(2.95,2.95), col = colGrid, lwd = ttest_line)
text(3.5,2.95,'***', pos = 1, col = colGrid, cex = p_value_txt)

#t.test(dID_new2$null_no_conf_conf, dID_new2$supra_yes_conf_conf, paired = TRUE)
# p-value = 0.01824
lines(c(1,4),c(2.7,2.7), col = colGrid, lwd = ttest_line)
text(2.5,2.7,'*', pos = 1, col = colGrid, cex = p_value_txt)