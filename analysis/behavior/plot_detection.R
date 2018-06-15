
# DATA - ALL --------------------------------------------------------------------

# Mean yes response rate
yes_resp <- data.frame(null_yes = dID_new2$null_yes,
                       near_yes = dID_new2$near_yes,
                       supra_yes = dID_new2$supra_yes)

# Number of trials
trial_n <- data.frame(null_n = dID_new2$null_n,
                       near_n = dID_new2$near_n,
                       supra_n = dID_new2$supra_n)

# Title
main_title <- substitute(paste('Detection (N = ', x, ')', sep = ''), list(x=nrow(yes_resp)))

# Category labels
cond_lab <- c('Catch', 'Near', 'Supra')


# DATA - CONFIDENT --------------------------------------------------------

# Mean yes response rate
yes_resp <- data.frame(null_yes = dID_new2$null_conf_yes,
                       near_yes = dID_new2$near_conf_yes,
                       supra_yes = dID_new2$supra_conf_yes)

# Number of trials
trial_n <- data.frame(null_n = dID_new2$null_conf_n,
                      near_n = dID_new2$near_conf_n,
                      supra_n = dID_new2$supra_conf_n)

# Title
main_title <- substitute(paste('Detection - Confident trials (N = ', x, ')', sep = ''), list(x=nrow(yes_resp)))

# Category labels
#cond_lab <- c('Catch_conf', 'Near_conf', 'Supra_conf')
cond_lab <- c('Catch', 'Near', 'Supra')

# DATA - UNCONFIDENT ------------------------------------------------------

# Mean yes response rate
yes_resp <- data.frame(null_yes = dID_new2$null_unconf_yes[!is.na(dID_new2$null_unconf_yes) & !is.na(dID_new2$near_unconf_yes) & !is.na(dID_new2$supra_unconf_yes)],
                       near_yes = dID_new2$near_unconf_yes[!is.na(dID_new2$null_unconf_yes) & !is.na(dID_new2$near_unconf_yes) & !is.na(dID_new2$supra_unconf_yes)],
                       supra_yes = dID_new2$supra_unconf_yes[!is.na(dID_new2$null_unconf_yes) & !is.na(dID_new2$near_unconf_yes) & !is.na(dID_new2$supra_unconf_yes)])

# Number of trials
trial_n <- data.frame(null_n = dID_new2$null_unconf_n,
                      near_n = dID_new2$near_unconf_n,
                      supra_n = dID_new2$supra_unconf_n)

# Title
main_title <- substitute(paste('Detection - Unconfident trials (',italic(N),'=', x, ')', sep = ''), list(x=nrow(yes_resp)))

# Condition labels
cond_lab <- c('Catch_unconf', 'Near_unconf', 'Supra_unconf')


# SETTINGS ----------------------------------------------------------------

# Y-axis label
y_axis_label <- 'Mean yes response rate'

# Category labels (x-axis)
x_labels <- c(paste(cond_lab[1],'\n(n~', round(mean(trial_n$null_n)), ')', sep = ''),
              paste(cond_lab[2],'\n(n~', round(mean(trial_n$near_n)), ')', sep = ''),
              paste(cond_lab[3],'\n(n~', round(mean(trial_n$supra_n)), ')', sep = ''))

# Create colormap
# http://colorbrewer2.org/#type=qualitative&scheme=Set3&n=4
colmap <- c(rgb(141,211,199, maxColorValue=255),
            rgb(255,255,179, maxColorValue=255),
            rgb(190,186,218, maxColorValue=255),
            rgb(251,128,114, maxColorValue=255))

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

# PLOT DETECTION ----------------------------------------------------------

# Plot settings
par(cex.main = 2.4,
    cex.lab = 2.0,
    cex.axis = 1.8,
    mar = c(4.5, 5.5, 4, 1),
    yaxs = 'i',
    xaxs = 'i',
    yaxt = 'n',
    xaxt = 'n',
    bty = 'o')

# Draw boxplot
boxplot(yes_resp,
        col=colmap[c(1,4,2)],
        range = 1.5)

# Draw line for 50%
abline(h = 0.5,
       lty = 2,
       col = 'black')

# Label line
text(.5,.52,'50%', pos = 4, col = 'black', cex = 1.8)

# Set title
title(main = main_title)

# Label y-axis
title(ylab = y_axis_label,
      line = 3.6)

# Activitate axes
par(xaxt = 's')
par(yaxt = 's')

axis(side = 2,
     at = seq(0, 1, .2),
     las = 1)

axis(side = 1,
     at = 1:3,
     labels = x_labels,
     mgp = c(3, 3, 0))