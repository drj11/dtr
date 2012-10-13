# Example: ghcnd.station('WF000917530')
ghcnd.station <- function(station) {
  filename <- paste('data/ghcnd_gsn/', station, '.dly', sep='')
  s <- read.fwf(filename, c(11,4,2,4,rep(c(5,3),31)), as.is=rep(6,66,2), sep='!', strip.white=FALSE)
  return(s)
}
ghcnd.station.element <- function(station, element) {
  s <- ghcnd.station(station)
  s <- s[s[,4]==element,]
  return(s)
}

ExpandDays <- function(x) {
  # Let *x* be a month index,
  # expand into a sequence of daily indexes.
  return((x*31-30):(x*31))
}
ghcnd.station.element.year <- function(station, element, year) {
  # A single year's worth of data is returned (as a vector).
  # -9999 is converted to NA
  s <- ghcnd.station(station)
  # Filter rows by element
  s <- s[s[,4]==element,]
  # Then extract year
  y <- s[s[,2]==year,]
  return(AsSingle(y))
}

MonthlyIndex <- function(base) {
  # For a given base year return a function that converts from
  # year, month to a single monthly index, for a series that
  # starts in January of the year *base*.
  # By convention m goes from 1 to 12.
  return(function(y,m) {
    return(12*(y-base)+m)
  })
}

ghcnd.station.element.as.single <- function(station, element) {
  # A station's entire daily record for a single element
  s <- ghcnd.station.element(station, element)
  return(AsSingle(s))
}
# Number of days in month for non-leap year.
kMonthLength <- c(31,28,31,30,31,30,31,31,30,31,30,31)
# Below, daily data is collected into years by pretending
# each month has 31 days (so a pretend year has 372 days);
# we use this mask to remove those pretend days. Note this
# also removes all genuine Feb 29s.
kYearMask <- floor(((seq(1,31*12)-1)%%31)+1) <= kMonthLength[ceiling(seq(1,31*12)/31)]

AsSingle <- function(s) {
  yearly.range = range(s[,2])
  # Number of years
  n = yearly.range[2] - yearly.range[1] + 1
  baseyear = yearly.range[1]
  mi = MonthlyIndex(baseyear)
  # monthly index for each (year,month) row in the station series.
  i <- as.numeric(Map(mi, s[,2], s[,3]))
  # Convert to daily index (two dimensional)
  d <- as.numeric(do.call(rbind, Map(ExpandDays, i)))
  res <- rep(NA, n*31*12)
  res[d] <- do.call(cbind, s[,seq(5,66,2)])

  flags = rep(NA, n*31*12)
  flags[d] <- as.matrix(s[,seq(6,66,2)])
  # Remove all data that is flagged in any way.
  res[substr(flags, 2,2) != " "] <- NA

  # And remove data with the MISSING value.
  res[res==-9999] <- NA

  # Compress by converting from pretend year (see above) to
  # real years.  Removes Feb 29 too.
  res <- res[which(rep(kYearMask, n))]
  return(res)
}
DailyAnomalies <- function(s) {
  # Convert a daily series (as returned by AsSingle) into
  # anomalies by subtracting from each element the average
  # for that day of the year.
  m <- matrix(s, ncol=365, byrow=TRUE)
  avg <- colMeans(m, na.rm=TRUE)
  # Recycling ftw!
  return(s-avg)
}
DailyAverage <- function(s) {
  # Return a vector of the averages for each day of the year
  # (the returned vector has length 365).
  m <- matrix(s, ncol=365, byrow=TRUE)
  avg <- colMeans(m, na.rm=TRUE)
  return(avg)
}
PlotAnom <- function(df) {
  # Given the data frame returned by station.element() function
  # (and friends), plot the series as anomalies.
  s = AsSingle(df)
  baseyear = min(df[,2])
  element = df[1,4]
  uid = df[1,1]
  plot(baseyear+((1:length(s))-0.5)/365, DailyAnomalies(s),
    ylab=paste(element, 'anomaly cK'), xlab='year', main=paste('GHCN-D', uid))
}
Plot <- function(df) {
  # Plot series from data frame.
  s = AsSingle(df)
  baseyear = min(df[, 2])
  element = df[1, 4]
  uid = df[1, 1]
  plot(baseyear+((1:length(s))-0.5)/365, s,
    ylab=paste(element, 'cK'), xlab='year', main=paste('GHCN-D', uid))
}

# source('ghcnd.R')
# s=ghcnd.station.element('UK000003808','TMIN')
# e=ghcnd.station.element.as.single('UK000003808','TMIN')
