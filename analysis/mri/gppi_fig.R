gppiSNIP <- read.table('/Users/martin/ownCloud/promotion/experiment/GraphCA/data/img_fMRI/gppi_power_NEW12/gPPI_snippet.1D')

# Create colormap
# http://colorbrewer2.org/#type=qualitative&scheme=Set3&n=4
colmap <- c(rgb(141,211,199, maxColorValue=255),
            rgb(255,255,179, maxColorValue=255),
            rgb(190,186,218, maxColorValue=255),
            rgb(251,128,114, maxColorValue=255))

#http://colorbrewer2.org/#type=qualitative&scheme=Dark2&n=4
colmap <- c('#1b9e77', '#d95f02', '#7570b3', '#e7298a')

#27,158,119
#217,95,2
#117,112,179
#231,41,138

# PLOT --------------------------------------------------------------------

line_w <- 5
TRs <- c(125:155)

par(mfrow=c(4,1),
    mar = c(0,0,0,0),
    xaxt = 'n',
    yaxt = 'n',
    ann = FALSE,
    bty = 'n')

# ROI_002
plot(TRs,
     gppiSNIP$V6[TRs],
     type = 'l',
     lty = 1,
     lwd = line_w,
     ylim = c(-1,1),
     col = colmap[1])

#abline(h=0)


# ROI_001
plot(TRs,
     gppiSNIP$V3[TRs],
     type = 'l',
     lty = 1,
     lwd = line_w,
     ylim = c(-1,1),
     col = colmap[3])

#abline(h=0)

# HRF
plot(TRs,
     gppiSNIP$V5[TRs],
     type = 'l',
     lty = 1,
     lwd = line_w,
     ylim = c(-.5,1.5),
     col = colmap[2])

#abline(h=0, col = 'black')

# PPI
plot(TRs,
     gppiSNIP$V2[TRs],
     type = 'l',
     lty = 1,
     lwd = line_w,
     ylim = c(-1,1),
     col = colmap[4])

#abline(h=0)
