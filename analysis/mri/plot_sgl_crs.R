# PLOT SIGNAL COURSE ------------------------------------------------------

plot_crs <- function(crs_d, sn, title_str, legend_pos) {
  
  # INPUT #
  
  # Input data reflects the mean signal time course for 1 ROI and all condition in long format
  
  # SETTINGS #
  
  # Variance measure
  #var_measure <- 'ci'
  var_measure <- 'se'
  
  # P-value threshold
  p_thr <- c(0.05, 0.01)
  
  # Time points
  tp <- as.numeric(levels(crs_d$t))
  
  # Font size
  ttl_fs <- 2.0
  axs_ttl_fs <- 1.6
  axs_fs <- 1.4
  p_fs <- 2
  p_lgnd_fs <- 1.4
  lgnd_fs <- 1.4
  
  ttest_lgnd <- 1.4
  
  lgnd_alpha <- 0.7
  
  # Colors
  # CR
  # Miss
  # Hit
  col <- matrix(c(27,158,119,
                  117,112,179,
                  217,95,2),
                nrow = 3,
                ncol = 3,
                byrow = TRUE)

  # Colors from plot_conf.R  
  # col <- matrix(c(141,211,199,
  #                 190,186,218,
  #                 251,128,114),
  #               nrow = 3,
  #               ncol = 3,
  #               byrow = TRUE)
  
  col <- col/255
  
  # Transparency of confidence band
  CI_alpha <- 0.5
  
  
  # # Average across participants
  # # columns = conditions
  # # rows = time points
  # crs_mean <- data.frame(CR = rowMeans(CR_crs),
  #                        miss = rowMeans(miss_crs),
  #                        hit = rowMeans(hit_crs))
  # 
  # # Compute confidence interval across participants
  # 
  # for (i in c(1:nrow(crs_mean))) {
  #   
  #   CI_data <- CR_crs[i,]
  #   CI_data[2,] <- miss_crs[i,]
  #   CI_data[3,] <- hit_crs[i,]
  #   
  #   rownames(CI_data) = c('CR','miss','hit')
  # 
  #   if (i == 1) {
  #     crs_CI <- matrix(within_CI(CI_data,CI_width))
  #   }
  #   else {
  #     crs_CI <- cbind(crs_CI, within_CI(CI_data,CI_width))
  #   }
  #   
  # }
  # 
  # crs_CI <- t(crs_CI)
  
  # T-Test for each time point between hits and misses
  p <- numeric(0)
  p_CR_miss <- numeric(0)
  p_CR_hit <- numeric(0)
  
  for (i in levels(sn$t)) {
    print(i)
    # hit vs. miss
    tstats <- t.test(sn$beta[sn$ROI==crs_d$ROI[1] & sn$cond == 'near_hit_conf' & sn$t == i]
                     - sn$beta[sn$ROI==crs_d$ROI[1] & sn$cond == 'near_miss_conf' & sn$t == i])
    print(tstats$p.value)
    p[i] <- tstats$p.value
    
    # CR vs. miss
    tstats2 <- t.test(sn$beta[sn$ROI==crs_d$ROI[1] & sn$cond == 'CR_conf' & sn$t == i]
                      - sn$beta[sn$ROI==crs_d$ROI[1] & sn$cond == 'near_miss_conf' & sn$t == i])
    print(tstats2$p.value)
    p_CR_miss[i] <- tstats2$p.value
    
    # CR vs. hit
    tstats3 <- t.test(sn$beta[sn$ROI==crs_d$ROI[1] & sn$cond == 'CR_conf' & sn$t == i]
                      - sn$beta[sn$ROI==crs_d$ROI[1] & sn$cond == 'near_hit_conf' & sn$t == i])
    print(tstats3$p.value)
    p_CR_hit[i] <- tstats3$p.value
  }
  
  # Prepare colors for plotting lines
  colmap <- c(rgb(col[1,1], col[1,2], col[1,3]),
              rgb(col[2,1], col[2,2], col[2,3]),
              rgb(col[3,1], col[3,2], col[3,3]))
  
  colmap2 <- c(rgb(col[1,1], col[1,2], col[1,3], lgnd_alpha),
               rgb(col[2,1], col[2,2], col[2,3], lgnd_alpha),
               rgb(col[3,1], col[3,2], col[3,3], lgnd_alpha))
  
  # Alternative with
  # spread(crs_d[,c(1:5)],cond,beta)[,c(4:6)],
  # dcast(crs_d, ROI + t ~ cond, value.var = 'beta')[,c(3:5)]
  
  # Do not plot x-axis
  par(xaxt = 'n',
      yaxt = 'n',
      mar = c(4, 4, 3, 1),
      mgp = c(2.75, 0.6, 0))
  
  # Plot lines
  #ylim = c(min(crs_d$beta - crs_d[, var_measure]),max(crs_d$beta + crs_d[, var_measure])),
  #ylim = c(-0.1,0.2),
  beta_range <- c(min(crs_d$beta - crs_d[, var_measure]),
                  max(crs_d$beta + crs_d[, var_measure]))
  
  beta_min2max <- sum(abs(beta_range))
  
  matplot(tp,
          data.frame(CR = crs_d$beta[crs_d$cond=='CR_conf'],
                     miss = crs_d$beta[crs_d$cond=='near_miss_conf'],
                     hit = crs_d$beta[crs_d$cond=='near_hit_conf']),
#          type = 'o',
          type = 'l',
          lty = c(3:1),
          lwd = 2,
          lend = 'butt',
#          pch = c(15,18,20),
          col = colmap[1:3],
          ylim = c(beta_range[1] - 0.3*beta_min2max, beta_range[2] + 0.1*beta_min2max),
          bty = 'l',
          ylab = 'Beta',
          xlab = 'Time in s (stimlus-locked)',
          cex.lab = axs_ttl_fs)
  
  title(main = title_str,
        cex.main = ttl_fs,
        font.main = 1)
  
  par(xaxt = 's',
      yaxt = 's')
  
  axis(1,
       at = seq(-6,12,3),
       cex.axis = axs_fs)
  
  rug(x = seq(-4.5,10.5,3),
      ticksize = -0.03,
      side = 1)
  
  axis(2,
       las = 1,
       #at = seq(-.1,.25,.1),
       cex.axis = axs_fs)
  
  abline(v = 0,
         lty = 5,
         lwd = 2,
         col = rgb(0.4,0.4,0.4,0.7))
  
  # Plot confidence interval band
  polygon(c(tp,rev(tp)),
          c(crs_d$beta[crs_d$cond=='CR_conf'] - subset(crs_d[, var_measure], crs_d$cond == 'CR_conf'),
            rev(crs_d$beta[crs_d$cond=='CR_conf'] + subset(crs_d[, var_measure], crs_d$cond == 'CR_conf'))),
          col = rgb(col[1,1], col[1,2], col[1,3], CI_alpha),
          border = NA)
  
  polygon(c(tp,rev(tp)),
          c(crs_d$beta[crs_d$cond=='near_miss_conf'] - subset(crs_d[, var_measure], crs_d$cond == 'near_miss_conf'),
            rev(crs_d$beta[crs_d$cond=='near_miss_conf'] + subset(crs_d[, var_measure], crs_d$cond == 'near_miss_conf'))),
          col = rgb(col[2,1], col[2,2], col[2,3], CI_alpha),
          border = NA)
  
  polygon(c(tp,rev(tp)),
          c(crs_d$beta[crs_d$cond=='near_hit_conf'] - subset(crs_d[, var_measure], crs_d$cond == 'near_hit_conf'),
            rev(crs_d$beta[crs_d$cond=='near_hit_conf'] + subset(crs_d[, var_measure], crs_d$cond == 'near_hit_conf'))),
          col = rgb(col[3,1], col[3,2], col[3,3], CI_alpha),
          border = NA)
  
  text(min(tp)*.94,
       beta_range[1] - 0.05*beta_min2max,
       labels = 'A-U',
       cex = ttest_lgnd)
  
  text(min(tp)*.94,
       beta_range[1] - 0.17*beta_min2max,
       labels = 'A-C',
       cex = ttest_lgnd)
  
  text(min(tp)*.94,
       beta_range[1] - 0.29*beta_min2max,
       labels = 'U-C',
       cex = ttest_lgnd)
  
  # Plot asteriks for significance
  if (any(p < p_thr[1] & p >= p_thr[2])) {
    
    text(tp[p < p_thr[1] & p >= p_thr[2]],
         beta_range[1] - 0.05*beta_min2max,
         #(crs_d$beta[crs_d$cond=='near_hit_conf' & p < p_thr[1] & p >= p_thr[2]]
         #+ crs_d$beta[crs_d$cond=='near_miss_conf' & p < p_thr[1] & p >= p_thr[2]])/2,
         labels = '*',
         cex = p_fs)
    
    # if (!any(p < p_thr[2])) {
    #   text(max(tp)+1,
    #        min(crs_d$beta - crs_d[, var_measure]) * 1.07,
    #        labels = expression(paste('* ', italic(P), ' < 0.05', sep = '')),
    #        pos = 2,
    #        cex = p_lgnd_fs)
    # }
    
  }
  
  if (any(p < p_thr[2])) {
    
    text(tp[p < p_thr[2]],
         beta_range[1] - 0.05*beta_min2max,
         #(crs_d$beta[crs_d$cond=='near_hit_conf'  & p < p_thr[2]]
         #+ crs_d$beta[crs_d$cond=='near_miss_conf'  & p < p_thr[2]])/2,
         labels = '**',
         cex = p_fs)
    
    # text(max(tp)+1,
    #      beta_range[1] - 0.29*beta_min2max,
    #      labels = expression(paste('* ', italic(P), ' < 0.05, **', italic(P), ' < 0.01', sep = '')),
    #      pos = 2,
    #      cex = p_lgnd_fs)
    
    if (crs_d$ROI[1] == 'lPCUN1') {
      text(max(tp)+1,
           #beta_range[2] + 0.1*beta_min2max,
           #beta_range[1] - 0.17*beta_min2max,
           beta_range[1] + 0.16*beta_min2max,
           labels = expression(paste('* ', italic(P), ' < 0.05', sep = '')),
           pos = 2,
           cex = p_lgnd_fs)
      
      text(max(tp)+1,
           #beta_range[2] - 0.02*beta_min2max,
           #beta_range[1] - 0.29*beta_min2max,
           beta_range[1] + 0.04*beta_min2max,
           labels = expression(paste('** ', italic(P), ' < 0.01', sep = '')),
           pos = 2,
           cex = p_lgnd_fs)
    }
  }
  
  # T-test CR vs. miss
  if (any(p_CR_miss < p_thr[1] & p_CR_miss >= p_thr[2])) {
    
    text(tp[p_CR_miss < p_thr[1] & p_CR_miss >= p_thr[2]],
         beta_range[1] - 0.29*beta_min2max,
         #(crs_d$beta[crs_d$cond=='CR_conf' & p_CR_miss < p_thr[1] & p_CR_miss >= p_thr[2]]
         #+ crs_d$beta[crs_d$cond=='near_miss_conf' & p_CR_miss < p_thr[1] & p_CR_miss >= p_thr[2]])/2,
         labels = '*',
         cex = p_fs,
         col = rgb(col[2,1], col[2,2], col[2,3]))
    
  }
  
  if (any(p_CR_miss < p_thr[2])) {
    
    text(tp[p_CR_miss < p_thr[2]],
         beta_range[1] - 0.29*beta_min2max,
         #(crs_d$beta[crs_d$cond=='CR_conf' & p_CR_miss < p_thr[2]]
         #+ crs_d$beta[crs_d$cond=='near_miss_conf'  & p_CR_miss < p_thr[2]])/2,
         labels = '**',
         cex = p_fs,
         col = rgb(col[2,1], col[2,2], col[2,3]))
    
  }
  
  # T-test CR vs. hit
  if (any(p_CR_hit < p_thr[1] & p_CR_hit >= p_thr[2])) {
    
    text(tp[p_CR_hit < p_thr[1] & p_CR_hit >= p_thr[2]],
         beta_range[1] - 0.17*beta_min2max,
         labels = '*',
         cex = p_fs,
         col = rgb(col[3,1], col[3,2], col[3,3]))
    
  }
  
  if (any(p_CR_hit < p_thr[2])) {
    
    text(tp[p_CR_hit < p_thr[2]],
         beta_range[1] - 0.17*beta_min2max,
         labels = '**',
         cex = p_fs,
         col = rgb(col[3,1], col[3,2], col[3,3]))
    
  }
  
  p_all <- data.frame(hit_miss = p,
                  CR_hit = p_CR_hit,
                  CR_miss = p_CR_miss)
  
  p_adj <- data.frame(hit_miss = p.adjust(p, 'fdr'),
                      CR_hit = p.adjust(p_CR_hit, 'fdr'),
                      CR_miss = p.adjust(p_CR_miss, 'fdr'))
  
  print(p_adj)
  
  p_adj2 <- p.adjust(c(p, p_CR_hit, p_CR_miss))
  
  print(t(p_adj2))
  
  legend(legend_pos,
         legend = rev(c('Control', 'Unaware', 'Aware')),
         col = rev(colmap2[1:3]),
         lwd = 10,
         lty = 1,#rev(c(3:1)),
         bty = 'n',
         cex = lgnd_fs,
         y.intersp = .8,
         seg.len = .8,
         inset = c(-.02,-.04),
         adj = 0.08)
  
}