#!/usr/bin/env Rscript

arg <- commandArgs(trailingOnly=TRUE)
print(arg)
stationid <- arg[1]
element <- arg[2]
source('ghcnd.R')

png(paste('work/', stationid, '-', element, '-anom.png', sep=''))
PlotAnom(ghcnd.station.element(stationid, element))
dev.off()
