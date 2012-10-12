# Notes on reading GHCND files with R.
# Code might not actually run.

# Notes use of c and rep to make the vector of column-widths
s=read.fwf('data/ghcnd_gsn/WF000917530.dly', c(11,4,2,4,rep(c(5,3),31)))
# Extract a single row:
s[894,]
# Extract only TMIN elements:
s[s[,4]=='TMIN',]
# (complex) get all flags for all months in 1971:
# (note: month attribute has been lost)
s=read.fwf('data/ghcnd_gsn/WF000917530.dly', c(11,4,2,4,rep(c(5,3),31)))
# Cute but wrong; it concatenates all months into one year, but goes wrong
# when there are missing months:
do.call(c, tmin[tmin[,2]==1977,][,5:66][,seq(1,62,2)])
# Extract single year:
tmin2008 <- tmin[tmin[,2]==2008,]
# A blank vector with 12*31 entries:
y1977 <- rep(NA,372)
# Fill in a single month, making it a nice numeric vector:
y1977[1:31] <- as.numeric(tmin1977[1,seq(5,66,2)])
# Fill in an entire year:
y1977[do.call(rbind, Map(function(x) (x*31-30):(x*31), tmin1977[,3]))] <- do.call(cbind, tmin1977[,seq(5,66,2)])
# Convert -9999 to NA:
y1977[y1977==-9999] = NA
