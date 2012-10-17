#!/usr/bin/env Rscript

arg <- commandArgs(trailingOnly=TRUE)
print(arg)
stationid <- arg[1]
element <- arg[2]
source('ghcn.R')

sl <- GHCNDStation(stationid, element)

png(paste('work/figure/', stationid, '-', element, '-anom.png', sep=''))
PlotAnom(sl)
dev.off()
png(paste('work/figure/', stationid, '-', element, '-abs.png', sep=''))
Plot(sl)
dev.off()
