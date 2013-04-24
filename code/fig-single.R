#!/usr/bin/env Rscript
png("work/b194901.png")
# Plot TMIN and TMAX for station USW00026615 1949-01
source('code/ghcn.R')
PlotSingleMonth('USW00026615', 1949, 1)
dev.off()

require('ggplot2')

png("work/USW00026615194901.png")
TStep(SingleMonth(GHCNDStationT('USW00026615'), 1949, 1))
dev.off()

png("work/s200502.png")
TStep(SingleMonth(GHCNDStationT('SZ000002220'), 2005, 2))
dev.off()

png("work/a198905.png")
TStep(SingleMonth(GHCNDStationT('AYW00090001'), 1989, 5))
dev.off()

png("work/AU000005010201204.png")
TStep(SingleMonth(GHCNDStationT('AU000005010'), 2012, 4))
dev.off()

png("work/USW00093820193511.png")
TStep(SingleMonth(GHCNDStationT('USW00093820'), 1935, 11))
dev.off()
