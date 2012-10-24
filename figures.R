#!/usr/bin/env Rscript

# Mostly just examples.
myRange <- function(a){
  # A range where the beginning and end
  # both have a fractional part exactly equal to 0.5.
  # So that 0 is exactly in the middle of a histogram bar.
  r=range(a)+c(-0.5,+0.5)
  r[1] = floor(r[1])+0.5
  r[2] = ceiling(r[2])-0.5
  return(r)
}
t=read.table("work/dmet.txt")
r=myRange(t[,3])
dmet=t[,3]
lat=t[,4]
elev=t[,6]
tmin=t[,8]
tmax=t[,9]
png("work/station-dmet.png")
hist(dmet, breaks=seq(r[1], r[2]),
  main="Station Average Monthly DMET",
  ylab="Station Count",
  xlab=expression("Average Monthly DMET ×10"^{-2}*"K"))
dev.off()
png("work/latitude-dmet.png")
plot(dmet,lat,
  xlab=expression("Average Monthly DMET (10"^-2*'K)'),
  ylab="Station Latitude (degrees)",
  main="Relationship between Latitude and DMET")
dev.off()
png("work/elevation-dmet.png")
plot(dmet,elev,
  xlab=expression("Average Monthly DMET (10"^-2*'K)'),
  ylab="Station Elevation (metres)",
  main="Relationship between Elevation and DMET")
dev.off()
png("work/latitude-length-dmet.png")
l=c('.','*','+','o','@')[1+floor(t[,7] / 500)]
plot(dmet,lat,pch=l,
  xlab=expression("Average Monthly DMET (10"^-2*'K)'),
  ylab="Station Latitude (degrees)",
  main="Relationship between Latitude and DMET")
dev.off()
png("work/euro-latitude.png")
euro=read.table('work/euro.txt')
edmet=euro[,3]
elat=euro[,4]
el=c('.','*','+','o','@')[1+floor(euro[,7] / 500)]
plot(edmet,elat,pch=el)
dev.off()
png("work/tmax-dmet.png")
plot(tmax,dmet)
abline(lm(dmet~tmax))
dev.off()

png("work/b194901.png")
# Plot TMIN and TMAX for station USW00026615 1949-01
source('ghcn.R')
PlotSingleMonth('USW00026615', 1949, 1)
dev.off()
