
ghcnm.station <-
function(station, file='work/dmet.ghcnv3') {
  # Extract all rows for a particular station from
  # a GHCN-M v3 file.
  s <- GHCNM(file=file)
  s <- s[s[, 1]==station, ]
  return(s)
}
GHCNM <- function(file='work/dmet.ghcnv3') {
  # Extract all rows from a GHCN-M v3 file.
  # :todo: Why does the as.is not work?
  s <- read.fwf(file, c(11, 4, 4, rep(c(5, 3), 12)),
    as.is=rep(5, 27, 2), sep='!', strip.white=FALSE)
  return(s)
}
  
ghcnm.station.element <-
function(station, element, file='work/dmet.ghcnv3') {
  # Extract all rows for a particular station,element
  # combination from a GHCN-M v3 file.
  s <- ghcnm.station(station, file=file)
  s <- s[s[, 3]==element, ]
  return(s)
}
Months <- function(s) {
  # Returns monthly data as single vector.
  #
  # Args:
  #   s: station object returned from ghcnm.station.element or friends.
  # Returns:
  #   Monthly data.

  r <- range(s[, 2])
  baseyear <- r[1]
  n <- r[2] - baseyear + 1
  # 2-dimensional array of indexes
  m <- do.call(rbind, Map(function(y)((y-baseyear)*12+1):((y-baseyear)*12+12), s[, 2]))
  res <- rep(NA, n*12)
  res[m] <- do.call(cbind, s[, seq(4, 27, 2)])
  # Remove data with the MISSING value.
  res[res==-9999] <- NA
  # Only appears in DMET, but still worth removing.
  res[res==8888] <- NA
  return(res)
}
ghcnm.station.list <-
function(station, element, file='work/dmet.ghcnv3') {
  # Return station as a list object.
  s <- ghcnm.station.element(station, element, file=file)
  m <- Months(s)
  if (is.element(element, c('TMIN', 'TMAX', 'MDTR', 'DMET'))) {
    m <- m * 0.01
  }
  r <- range(s[, 2])
  res <- list(uid=station, df=s, baseyear=r[1], lastyear=r[2], element=element, series=m)
  return(res)
}
PlotM <- function(sl) {
  # Basic plot of monthly data.
  #
  # Args:
  #   sl: station object returned from ghcnm.station.list
  # Returns:
  #   The x and y vectors used in the plot, as $x and $y
  #   of the returned list.
  unit <- 'mystery units'
  if (is.element(sl$element, c('TMIN', 'TMAX'))) {
    unit <- 'C'
  }
  if (is.element(sl$element, c('MDTR', 'DMET'))) {
    unit <- 'K'
  }
  ylab <- paste(sl$element, unit, sep=' ')
  x <- sl$baseyear+((1:length(sl$series))-0.5)/12
  y <- sl$series
  plot(x, y,
    main=paste('GHCN-D ', sl$uid, sep=''), xlab='year', ylab=ylab)
  return(list(x=x, y=y))
}

ExpandDays <- function(m) {
  # Compute the days of a pretend year that a month covers.
  #
  # Args:
  #   m: month index, from 1 to 12.
  # Returns:
  #   A vector; always 31 elements long.
  return((m*31-30):(m*31))
}
# Example: ghcnd.station('WF000917530')
ghcnd.station <- function(station='', dirname='data/ghcnd_gsn', filename='') {
  # Return the rows of a GHCN-D format file.
  #
  # Args:
  #   station: If supplied, specifies the filename to open, in combination
  #     with the dirname argument.
  #   dirname: Specifies the directory of files to use when the station
  #     argument is used.
  #   filename: The filename to open (if station argument is not supplied)
  if (station != '') {
    filename <- paste(dirname, '/', station, '.dly', sep='')
  }
  s <- read.fwf(filename, c(11, 4, 2, 4, rep(c(5, 3), 31)),
    as.is=rep(6, 66, 2), sep='!', strip.white=FALSE)
  return(s)
}
ghcnd.station.element <- function(station, element) {
  s <- ghcnd.station(station)
  s <- s[s[, 4]==element, ]
  return(s)
}
ghcnd.station.element.year <- function(station, element, year) {
  # A single year's worth of data.
  #
  # Args:
  #   station: uid for station.
  #   element: 4-character code for element.
  #   year: year
  # Returns:
  #   A single vector of daily data.
  
  s <- ghcnd.station(station)
  # Filter rows by element
  s <- s[s[, 4]==element, ]
  # Then extract year
  y <- s[s[, 2]==year, ]
  return(AsSingle(y))
}

MonthlyIndex <- function(base) {
  # Function for computing the index from a month.
  #
  # Args:
  #   base: the base year
  # Returns:
  #   A function(y, m) that computes the month index
  #   for year y month m into a series beginning in
  #   year base.  Note by convention m goes from 1 to 12.
  return(function(y, m) {
    return(12*(y-base)+m)
  })
}

GHCNDStation <- function(station, element) {
  # Return a station as a list object.
  s <- ghcnd.station.element(station, element)
  d <- AsSingle(s)
  if (is.element(element, c('TMIN', 'TMAX', 'MDTR'))) {
    d <- d * 0.1
  }
  r <- range(s[, 2])
  res <- list(uid=station, df=s, baseyear=r[1], lastyear=r[2], element=element, series=d)
  return(res)
}

GHCNDStationT <- function(station='', rm.flag=TRUE, filename='') {
  rows <- ghcnd.station(station=station, filename=filename)
  yearly.range <- range(rows[, 2])
  tmin = rows[rows[, 4] == 'TMIN', ]
  tmax = rows[rows[, 4] == 'TMAX', ]
  tmin = AsSingle(tmin, yearly.range, rm.flag=rm.flag)
  tmax = AsSingle(tmax, yearly.range, rm.flag=rm.flag)
  tmin <- tmin * 0.1
  tmax <- tmax * 0.1
  df = data.frame(tmin=tmin, tmax=tmax)
  uid <- unique(rows[, 1])
  res <- list(uid=uid, first=c(yearly.range[1], 1, 1),
    element=c('TMIN', 'TMAX'),
    baseyear=yearly.range[1], lastyear=yearly.range[2], rows=rows, data=df)
  return(res)
}
SingleYear <- function(sl, year) {
  # Extract a single year from the station list sl, returning a new list.
  if (sl$first[2] != 1 || sl$first[3] != 1) {
    return(NA)
  }
  n = year - sl$first[1]
  if (n < 0) {
    return(NA)
  }
  df <- sl$data[(n*365+1):(n*365+365), ]
  res <- list(uid=sl$uid, first=c(year, 1, 1),
    element=c('TMIN', 'TMAX'),
    data=df)
  return(res)
}

StationSingleMonth <- function(stationid, year, month) {
  tminall <- GHCNDStation(stationid, 'TMIN')
  tmaxall <- GHCNDStation(stationid, 'TMAX')
  tmin = YM(tminall, year, month)
  tmax = YM(tmaxall, year, month)
  # :todo: the data should be a data frame with columns tmin and tmax.
  return(list(uid=stationid, first=c(year, month, 1), element=c('TMIN', 'TMAX'),
    data=data.frame(tmin=tmin, tmax=tmax)))
}

YM <- function(sl, year, month) {
  # Extract a single month from a (daily) station.

  # Number of days between Jan 1 and start of month.
  moff = sum(kMonthLength[0:(month-1)])
  # Number of days between start of series and start of year.
  yoff = 365 * (year - sl$baseyear)
  p = yoff + moff + 1
  q = yoff + moff + kMonthLength[month]
  return(sl$series[p:q])
}

# Number of days in month for non-leap year.
kMonthLength <- c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)

# Below, daily data is collected into years by pretending
# each month has 31 days (so a pretend year has 372 days);
# we use this mask to remove those pretend days. Note this
# also removes all genuine Feb 29s.
kYearMask <- floor(((seq(1, 31*12)-1)%%31)+1) <=
             kMonthLength[ceiling(seq(1, 31*12)/31)]

AsSingle <- function(s, yearly.range=NA, rm.flag=TRUE) {
  # Returns daily data as a single vector.
  #
  # Args:
  #   s: a station object returned from ghcnd.station.element or friends.
  #   yearly.range: if supplied (as a length 2 vector), stretch the result
  #     out to include all of the specified years (padded with NA).  Note
  #     that it can only be used to stretch, not shrink.
  #   rm.flag: If TRUE then flagged data is removed (set to NA).
  # Returns:
  #  Daily data.
  if (length(yearly.range) < 2) {
    yearly.range <- range(s[, 2])
  }
  # Number of years
  n <- yearly.range[2] - yearly.range[1] + 1
  baseyear <- yearly.range[1]
  mi <- MonthlyIndex(baseyear)
  # monthly index for each (year, month) row in the station series.
  i <- as.numeric(Map(mi, s[, 2], s[, 3]))
  # Convert to daily index (two dimensional)
  d <- as.numeric(do.call(rbind, Map(ExpandDays, i)))
  res <- rep(NA, n*31*12)
  res[d] <- do.call(cbind, s[, seq(5, 66, 2)])

  flags <- rep(NA, n*31*12)
  flags[d] <- as.matrix(s[, seq(6, 66, 2)])
  # Remove all data that is flagged in any way.
  if (rm.flag) {
    res[substr(flags, 2, 2) != " "] <- NA
  }

  # And remove data with the MISSING value.
  res[res==-9999] <- NA

  # Compress by converting from pretend year (see above) to
  # real years.  Removes Feb 29 too.
  res <- res[which(rep(kYearMask, n))]
  return(res)
}
DailyAnomalies <- function(s) {
  # Compute daily anomalies (by subtracting from each element the
  # average for that day of the year).
  #
  # Args:
  #   s: single vector of daily data (eg returned from AsSingle()).
  # Returns:
  #   A vector of anomalies.

  m <- matrix(s, ncol=365, byrow=TRUE)
  avg <- colMeans(m, na.rm=TRUE)
  # Recycling ftw!
  return(s-avg)
}

DailyAverage <- function(s) {
  # Compute average value for each day of the year.
  #
  # Args:
  #   s: single vector of daily data (eg returned from AsSingle()).
  # Returns:
  #   A vector of averages (has length 365).

  m <- matrix(s, ncol=365, byrow=TRUE)
  avg <- colMeans(m, na.rm=TRUE)
  return(avg)
}
PlotAnom <- function(sl) {
  # Plot a (daily) station series as anomalies.
  s <- DailyAnomalies(sl$series)
  .Plot(sl, s, extra.label=' anomaly')
}
Plot <- function(sl, extra.label='') {
  # Plot a (daily) station series, as returned by GHCNDStation.
  .Plot(sl, sl$series)
}
PlotSeasonal <- function(sl) {
  # A plot showing 2 seasonal cycles from the daily station series,
  # as returned by GHCNDStation.
  avg <- DailyAverage(sl$series)
  .Plot(sl, c(avg, avg), extra.label=' cycle', baseyear.label=FALSE)
}
.Plot <- function(sl, series, extra.label='', baseyear.label=TRUE) {
  # Plots the vector series, labelling using metadata
  # from sl.
  unit <- ''
  if (sl$element == 'TMIN' || sl$element == 'TMAX') {
      unit <- ' K'
  }
  if (baseyear.label) {
      base <- sl$baseyear
  } else {
      base <- 0
  }
  plot(base+((1:length(series))-0.5)/365, series,
    ylab=paste(sl$element, extra.label, unit, sep=''),
    xlab='year', main=paste('GHCN-D', sl$uid))
}
PlotZeroes <- function(df) {
  # Plot showing the number of 0 values in each year.
  s <- AsSingle(df)
  element <- df[1, 4]
  uid <- df[1, 1]
  m <- matrix(s, ncol=365, byrow=TRUE)
  r <- range(df[, 2])
  plot(r[1]:r[2], rowSums(m==0, na.rm=TRUE),
    ylab='zero count', xlab='year', main=paste('GHCN-D', uid))
}


PlotSingleMonth <- function(stationid, year, month) {
  # Plot TMIN and TMAX for a single month at a single station
  tminall <- GHCNDStation(stationid, 'TMIN')
  tmaxall <- GHCNDStation(stationid, 'TMAX')
  tmin = YM(tminall, year, month)
  tmax = YM(tmaxall, year, month)
  # 1 where min exists and max doesn't.
  minpoints = (!is.na(tmin)) * is.na(tmax)
  minpoints[minpoints == 0] <- NA
  # 1 where max exists and min doesn't.
  maxpoints = (!is.na(tmax)) * is.na(tmin)
  maxpoints[maxpoints == 0] <- NA
  plot(x=rep(1:length(tmin),2), y=c(tmin,tmax), pch=c(minpoints,maxpoints),
    xlab='day', ylab='temperature, ℃',
    main=paste('GHCN-D', stationid, sprintf('%04d-%02d', year, month), 'TMAX,TMIN'),
    ylim=range(tmax, tmin, na.rm=TRUE))
  lines(ts(tmax), col='red')
  lines(ts(tmin), col='blue')
}
TStep <- function(sl) {
  # Plot TMIN and TMAX as a staircase.
  df <- data.frame(sl$data, day=1:length(sl$data[,1]))
  # TRUE where min exists and max doesn't.
  minpoints = (!is.na(df$tmin)) & is.na(df$tmax)
  minpoints[minpoints == 0] <- NA
  # TRUE where max exists and min doesn't.
  maxpoints = (!is.na(df$tmax)) & is.na(df$tmin)
  maxpoints[maxpoints == 0] <- NA
  isodate <- sprintf('%04d-%02d-%02d', sl$first[1], sl$first[2], sl$first[3])
  ggplot(df) + geom_step(aes(x=day, y=tmax, colour='tmax')) +
    geom_step(aes(x=day, y=tmin, colour='tmin')) +
    labs(title=paste('GHCN-D', sl$uid, isodate), colour='element', y='temperature, ℃')
}

# source('ghcnd.R')
# s <- ghcnd.station.element('UK000003808', 'TMIN')
# m <- ghcnm.station.element('UK000003808', 'MDTR')
