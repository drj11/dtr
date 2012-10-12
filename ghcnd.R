# Example: ghcnd.station('WF000917530')
ghcnd.station <- function(station) {
  filename <- paste('data/ghcnd_gsn/', station, '.dly', sep='')
  s <- read.fwf(filename, c(11,4,2,4,rep(c(5,3),31)))
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
  res = rep(NA,31*12)
  res[do.call(rbind, Map(ExpandDays, y[,3]))] <- do.call(cbind, y[,seq(5,66,2)])
  res[res==-9999] = NA
  return(res)
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
  s <- ghcnd.station(station)
  s <- s[s[,4]==element,]
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
  res[res==-9999] <- NA
  return(res)
}
