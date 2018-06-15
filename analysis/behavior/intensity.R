
# Near-treshold intensity -------------------------------------------------

mean(dID_new2$near_intensity)
# 1.85

range(dID_new2$near_intensity)
# [1.01 2.58]

sd(dID_new2$near_intensity)
# 0.46

cor.test(dID_new2$near_intensity,dID_new2$near_yes)
# -0.14, p = .54

cor.test(dID_new2$near_intensity1,dID_new2$near_yes1)
cor.test(dID_new2$near_intensity2,dID_new2$near_yes2)
cor.test(dID_new2$near_intensity3,dID_new2$near_yes3)
cor.test(dID_new2$near_intensity4,dID_new2$near_yes4)


# Supra-treshold intesnity ------------------------------------------------

mean(dID_new2$supra_intensity)
# 2.19 mA

range(dID_new2$supra_intensity)
# [1.41 2.98]

sd(dID_new2$supra_intensity)
# 0.46

# Supra/near
mean(dID_new2$supra_intensity/dID_new2$near_intensity-1)
# 20%

mean(dID_new2$supra_intensity-dID_new2$near_intensity)
# 0.34 mA

# PLOT --------------------------------------------------------------------


i <- 1

col <- rainbow(length(dID_new2$ID))
#col <- terrain.colors(length(dID_new2$ID))



# plot(0,0,
#      xlim = c(0.9,2.9),
#      ylim = c(0,1),
#      xlab = "Near-threshold intensity in mA",
#      ylab = "Near-threshold yes response ratio")
# 

#title("Detection(intentsity) per participant")

intens_width <- matrix(0,length(dID_new2$ID),4)

intens_miss_hit <- matrix(0,length(dID_new2$ID),2)

slope <- matrix(0,length(dID_new2$ID),2)

j <- 0

par(mfrow=c(5,5),
    mar = rep(2, 4))

for (i in dID_new2$ID) {
  
  j <- j + 1
  
  intens <- na.omit(c(dID_new2$near_intensity1[dID_new2$ID==i],
                      dID_new2$near_intensity2[dID_new2$ID==i],
                      dID_new2$near_intensity3[dID_new2$ID==i],
                      dID_new2$near_intensity4[dID_new2$ID==i]))
  
  detect <- na.omit(c(dID_new2$near_yes1[dID_new2$ID==i],
                      dID_new2$near_yes2[dID_new2$ID==i],
                      dID_new2$near_yes3[dID_new2$ID==i],
                      dID_new2$near_yes4[dID_new2$ID==i]))
  
  intens_width[j,1:2] <- range(intens, na.rm = TRUE)
  
  intens_width[j,3] <- intens_width[j,2]-intens_width[j,1]
  
  intens_width[j,4] <- (intens_width[j,2]/intens_width[j,1])-1
  
  intens_miss_hit[j,1:2] <- c(weighted.mean(intens,detect, na.rm = TRUE),
                              weighted.mean(intens,1-detect, na.rm = TRUE))
  
  # -mean(intens)/max(intens)

  title(i)
  
  # plot(na.omit(intens),
  #      na.omit(detect),
  #      type = "l",
  #      col = col[j],
  #      ylim = c(0,1),
  #      lty = 1,
  #      lwd = 2)
  
  plot(sort(intens),
       detect[order(intens)],
       type = "p",
       col = col[j],
       ylim = c(0,1),
       lty = 1,
       lwd = 2)
  
  abline(v=intens_miss_hit[j,1],
         lty = 2,
         lwd = 2)
  
  abline(v=intens_miss_hit[j,2],
         lty = 1,
         lwd = 2)
  
  z <- line(intens,
            detect)
  
  slope[j,1:2] <- coef(z)
  
  abline(coef(z))

  # lines(intens,detect,
  #      type = "l",
  #      col = col[j],
  #      xlim = c(0,3),
  #      ylim = c(0,1),
  #      lty = 1,
  #      lwd = 5)

}

boxplot(intens_miss_hit)

# mean(intens_width[,3])
# 0.22
# range(intens_width[,3])
# 0.02 0.77

# mean(intens_width[,4])
# 0.14 # -> mean distance from minium to maxium 14%
# range(intens_width[,4])
# 0.01 0.37

# colMeans(intens_miss_hit)
# 1.868939 1.831160

# t.test(intens_miss_hit[,1],intens_miss_hit[,2],paired = TRUE)
# 0.03, p = .004

