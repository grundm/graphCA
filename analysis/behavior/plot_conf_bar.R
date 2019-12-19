# DATA PREPARING ----------------------------------------------------------

library(tidyr)

colmap <- c(rgb(141,211,199, maxColorValue=255),
            rgb(190,186,218, maxColorValue=255),
            rgb(251,128,114, maxColorValue=255),
            rgb(255,255,179, maxColorValue=255))

newD3 <- dID1[c('ID', 'null_no_conf1', 'null_no_conf2', 'null_no_conf3', 'null_no_conf4',
                'supra_yes_conf1', 'supra_yes_conf2', 'supra_yes_conf3', 'supra_yes_conf4',
                'near_miss_conf1', 'near_miss_conf2', 'near_miss_conf3', 'near_miss_conf4',
                'near_hit_conf1', 'near_hit_conf2', 'near_hit_conf3', 'near_hit_conf4')]

newD3[2:5] <- newD3[2:5]/dID1$null_no_n
newD3[6:9] <- newD3[6:9]/dID1$supra_yes_n
newD3[10:13] <- newD3[10:13]/dID1$near_miss_n
newD3[14:17] <- newD3[14:17]/dID1$near_hit_n

tmpD3 <- gather(newD3, cond, probs, null_no_conf1:near_hit_conf4)

data3 <- separate(tmpD3, cond, into = c('stimulus', 'detection', 'confidence'), sep = '_', extra = 'merge')

data3$detection[data3$detection == "no"] <- "a_null_no"
data3$detection[data3$detection == "miss"] <- "b_near_miss"
data3$detection[data3$detection == "hit"] <- "c_near_hit"
data3$detection[data3$detection == "yes"] <- "d_supra_hit"

# BARPLOT -----------------------------------------------------------------

code_dir <- '~/ownCloud/promotion/experiment/GraphCA/graphca/'

source(paste(code_dir, 'assets/CI_within_helper.R', sep = '/'))

smd <- summarySEwithin(data=data3, 'probs', withinvars=c('detection','confidence'),
                       idvar='ID', na.rm=FALSE, conf.interval=.95, .drop=TRUE)

prob_mean <- smd$probs[order(smd$confidence)]
prob_ci <- smd$ci[order(smd$confidence)]


# BARPLOT PLOTTING --------------------------------------------------------


barcenters <- barplot(smd$probs[order(smd$confidence)],
                      ylab = 'Probability(Confidence|Detection)',
                      col = colmap,
                      ylim = c(0,0.8))

segments(barcenters, prob_mean - prob_ci, barcenters,
         prob_mean + prob_ci, lwd = 1)

arrows(barcenters, prob_mean - prob_ci, barcenters,
       prob_mean + prob_ci, lwd = 1, angle = 90,
       code = 3, length = 0.05)

axis(side = 1,
     at = c(mean(barcenters[2:3]),mean(barcenters[6:7]),mean(barcenters[10:11]),mean(barcenters[14:15])),
     tick = FALSE,
     labels = c('very\nunconfident', 'rather\nunconfident', 'rather\nconfident', 'very\nconfident'))

legend('topleft',
       legend=c('Correct rejection','Near-miss', 'Near-hit', 'Supra-hit'),
       fill= colmap[1:4],
       horiz = TRUE,
       cex = 0.8,
       bty = 'n')

# * p < 0.05
# ** p < 0.001
# *** p < 0.00001

p_value_txt <- 1.2

ttest_conf1 <- pairwise.t.test(data3$probs[data3$confidence=='conf1'],data3$detection[data3$confidence=='conf1'],paired = TRUE,p.adjust.method = 'none')
ttest_conf2 <- pairwise.t.test(data3$probs[data3$confidence=='conf2'],data3$detection[data3$confidence=='conf2'],paired = TRUE,p.adjust.method = 'none')
ttest_conf3 <- pairwise.t.test(data3$probs[data3$confidence=='conf3'],data3$detection[data3$confidence=='conf3'],paired = TRUE,p.adjust.method = 'none')
ttest_conf4 <- pairwise.t.test(data3$probs[data3$confidence=='conf4'],data3$detection[data3$confidence=='conf4'],paired = TRUE,p.adjust.method = 'none')

pvalues <- c(diag(ttest_conf1$p.value),diag(ttest_conf2$p.value),diag(ttest_conf3$p.value),diag(ttest_conf4$p.value))

pvalues_fdr <- p.adjust(t(pvalues),'fdr')

# Conf 1 (CR vs. near-miss)
lines(barcenters[1:2],c(0.12,0.12), col = 1, lwd = 1)
#text(mean(barcenters[1:2]),0.11,'p = 0.013', pos = 3, col = 1, cex = .8)
# FDR-corrected: pvalues_fdr[1] = 0.023
text(mean(barcenters[1:2]),0.11,'*', pos = 3, col = 1, cex = p_value_txt)

# Conf 1 (Near-miss vs. near-hit)
lines(barcenters[2:3],c(0.27,0.27), col = 1, lwd = 1)
#text(mean(barcenters[2:3]),0.26,'p = 0.0004', pos = 3, col = 1, cex = .8)
# FDR-corrected: pvalues_fdr[2] = 0.00086
text(mean(barcenters[2:3]),0.26,'**', pos = 3, col = 1, cex = p_value_txt)

# Conf 1 (Near-hit vs. supra-hit)
lines(barcenters[3:4],c(0.20,0.20), col = 1, lwd = 1)
#text(mean(barcenters[3:4]),0.19,'p = 0.00005', pos = 3, col = 1, cex = .8)
# FDR-corrected: pvalues_fdr[3] = 0.00012
text(mean(barcenters[3:4]),0.19,'**', pos = 3, col = 1, cex = p_value_txt)

# Conf 2 (CR vs. near-miss)
lines(barcenters[5:6],c(0.30,0.30), col = 1, lwd = 1)
#text(mean(barcenters[5:6]),0.29,'p = 0.000003', pos = 3, col = 1, cex = .8)
# FDR-corrected: pvalues_fdr[4] = 0.0000091
text(mean(barcenters[5:6]),0.29,'***', pos = 3, col = 1, cex = p_value_txt)

# Conf 2 (Near-hit vs. supra-hit)
lines(barcenters[7:8],c(0.30,0.30), col = 1, lwd = 1)
#text(mean(barcenters[7:8]),0.33,'p = 0.00000001', pos = 3, col = 1, cex = .8)
# FDR-corrected: pvalues_fdr[6] = 0.000000069
text(mean(barcenters[7:8]),0.29,'***', pos = 3, col = 1, cex = p_value_txt)

# Conf 3 (Near-hit vs. supra-hit)
lines(barcenters[11:12],c(0.40,0.40), col = 1, lwd = 1)
#text(mean(barcenters[11:12]),0.39,'p = 0.02', pos = 3, col = 1, cex = .8)
# FDR-corrected: pvalues_fdr[9] = 0.027
text(mean(barcenters[11:12]),0.39,'*', pos = 3, col = 1, cex = p_value_txt)

# Conf 4 (CR vs. near-miss)
lines(barcenters[13:14],c(0.69,0.69), col = 1, lwd = 1)
#text(mean(barcenters[13:14]),0.68,'p = 0.000001', pos = 3, col = 1, cex = .8)
#FDR-corrected: pvalues_fdr[10] = 0.0000056
text(mean(barcenters[13:14]),0.68,'***', pos = 3, col = 1, cex = p_value_txt)

# Conf 4 (Near-miss vs. near-hit)
lines(barcenters[14:15],c(0.50,0.50), col = 1, lwd = 1)
#text(mean(barcenters[14:15]),0.49,'p = 0.028', pos = 3, col = 1, cex = .8)
#FDR-corrected: pvalues_fdr[11] = 0.037
text(mean(barcenters[14:15]),0.49,'*', pos = 3, col = 1, cex = p_value_txt)

# Conf 4 (Near-hit vs. supra-hit)
lines(barcenters[15:16],c(0.72,0.72), col = 1, lwd = 1)
#text(mean(barcenters[15:16]),0.74,'p = 1.9e-13', pos = 3, col = 1, cex = .8)
#FDR-corrected: pvalues_fdr[12] = 0.000000000002
text(mean(barcenters[15:16]),0.71,'***', pos = 3, col = 1, cex = p_value_txt)

text(1.5,
     0.6,
     labels = '* P < 0.05\n** P < 0.001\n*** P < 0.00001',
     pos = 3,
     cex = 0.8)
