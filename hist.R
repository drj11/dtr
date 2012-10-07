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
r=myRange(data.matrix(t[3]))
dmet=do.call(c, t[3])
lat=do.call(c, t[4])
elev=do.call(c, t[6])
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
l=c('.','*','+','o','@')[1+floor(do.call(c, t[7]) / 500)]
plot(dmet,lat,pch=l,
  xlab=expression("Average Monthly DMET (10"^-2*'K)'),
  ylab="Station Latitude (degrees)",
  main="Relationship between Latitude and DMET")
dev.off()
