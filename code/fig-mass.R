#!/usr/bin/env Rscript

require('ggplot2')

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
t=read.table('work/dmet.txt',
  col.names=c('uid', 'extreme', 'mean', 'latitude', 'longitude', 'elevation', 'n', 'tmin.avg', 'tmax.avg'))
r=myRange(t$mean)
# dmet=t[,3]
# lat=t[,4]
# elev=t[,6]
# tmin=t[,8]
# tmax=t[,9]
png("work/station-dmet.png")
ggplot(t) + geom_histogram(aes(x=mean), breaks=seq(r[1], r[2]),
  main="Station Average Monthly DMET",
  ylab="Station Count",
  xlab=expression("Average Monthly DMET ×10"^{-2}*"K"))
dev.off()
png("work/latitude-dmet.png")
plot(t$mean,t$latitude,
  xlab=expression("Average Monthly DMET (10"^-2*'K)'),
  ylab="Station Latitude (degrees)",
  main="Relationship between Latitude and DMET")
dev.off()
png("work/elevation-dmet.png")
plot(t$mean,t$elevation,
  xlab=expression("Average Monthly DMET (10"^-2*'K)'),
  ylab="Station Elevation (metres)",
  main="Relationship between Elevation and DMET")
dev.off()
png("work/latitude-length-dmet.png")
l=c('.','*','+','o','@')[1+floor(t$n / 500)]
plot(t$mean,t$latitude,pch=l,
  xlab=expression("Average Monthly DMET (10"^-2*'K)'),
  ylab="Station Latitude (degrees)",
  main="Relationship between Latitude and DMET")
dev.off()

png("work/euro-latitude.png")
euro=read.table('work/euro.txt',
  col.names=c('uid', 'extreme', 'mean', 'latitude', 'longitude', 'elevation', 'n', 'tmin.avg', 'tmax.avg'))
el=c('.','*','+','o','@')[1+floor(euro$n / 500)]
plot(euro$mean,euro$latitude,pch=el)
dev.off()

png("work/tmax-dmet.png")
plot(t$tmax.avg,t$mean)
abline(lm(t$tmax.avg~t$mean))
dev.off()
