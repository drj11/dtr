#!/usr/bin/env python

"""Handle data in GHCN-D format.
See ftp://ftp.ncdc.noaa.goc/pub/data/ghcn/daily/readme.txt for
details of the format (and location of the GHCN-D data).
"""

import itertools
import os
import warnings

class Series:
    """When populated, self.data will be a data series for a
    particular element (specified by self.element).
    That value will be a list with one item per month, beginning with
    January of self.firstyear, each month will be a list of values for
    each day.  Missing data will appear as the value *None*
    """

    def __init__(self, **k):
        self.data = []
        self.firstyear = None
        self.element = None
        self.__dict__.update(k)

    def __repr__(self):
        return ("Series(uid=%(uid)r, element=%(element)r, firstyear=%(firstyear)r)" %
          self.__dict__)

    def scaleFactor(self):
        """The scale value from units stored in the file to the
        natural units store in this object.  For TMIN and TMAX
        it is 0.1 (units of 0.1 C).
        """

        if self.element in ('TMIN', 'TMAX'):
            return 0.1
        raise Exception("Can't find scale for element %s" % self.element)

    def append(self, row):
        """Append a row of data.  *row* is a dict.  *row['element']*
        gives the (4 character) element type.  *row['year']* and *row['month']*
        give the time.  *row['data']* is the data as a flat string (the
        concatenation of 31 8-character sequences).
        """

        if self.element is None:
            warnings.warn('self.element is not set, data unlikely to be collected.')
        element = row['element']
        if element != self.element:
            return
        if self.firstyear is None:
            self.firstyear = row['year']

        if 'month' in row:
            return self.appendMonth(row)
        return self.appendYear(row)

    def appendMonth(self, row):
        # Pad out data if neccesary to cope with gaps.
        offset = 12*(row['year'] - self.firstyear) + row['month'] - 1
        assert offset >= len(self.data), "%(uid)s%(year)d%(month)02d time reversal" % row
        while offset > len(self.data):
            year = self.firstyear + len(self.data) // 12
            month = len(self.data) % 12 + 1
            pad = [None for n in range(month_length(year, month))]
            self.data.append(pad)

        nitems = month_length(row['year'], row['month'])
        m = []
        for i in range(nitems):
            s = row['data'][8*i:8*(i+1)]
            v = s[:5]
            flags = s[5:]
            v = int(v)
            if v != -9999:
                if flags[1] != ' ':
                    v = None
                else:
                    if self.scale:
                        v *= self.scaleFactor()
            else:
                v = None
            m.append(v)
        self.data.append(m)

    def appendYear(self, row):
        m = []
        for i in range(12):
            s = row['data'][8*i:8*(i+1)]
            v = s[:5]
            flags = s[5:]
            v = int(v)
            if v != -9999:
                if flags[1] != ' ':
                    v = None
                else:
                    v *= 0.01
            else:
                v = None
            m.append(v)
        self.data.append(m)


class Record:
    """Record multiple series for a given station."""

    def __init__(self, **k):
        self.element = []
        self.series = {}
        self.firstyear = None
        self.__dict__.update(k)
        if 'element' in k:
            del k['element']
        for elem in self.element:
            self.series[elem] = Series(element=elem, **k)

    def append(self, row):
        elem = row['element']
        if elem not in self.element:
            return
        if self.firstyear is None:
            self.firstyear = row['year']
            for s in self.series.values():
                s.firstyear = self.firstyear
        self.series[elem].append(row)

def month_length(year, month):
    """Return number of days in month."""
    if month == 2:
        import datetime
        for n in [29,28]:
            try:
                datetime.date(year, month, n)
                return n
            except ValueError:
                pass
        assert 0, "%04d%02d month length" % (year, month)
    if month <= 7:
       return 30 + month%2
    else:
       return 31 - month%2


ghcnd_fields = dict(
    uid=        (0,  11, str),
    year=       (11, 15, int),
    month=      (15, 17, int),
    element=    (17, 21, str),
    data=       (21, 269, str)
).items()

ghcnm_fields = dict(
    uid=        (0,  11, str),
    year=       (11, 15, int),
    element=    (15, 19, str),
    data=       (19, 115, str)
).items()

def rowtodict(l):
    return dict((field, convert(l[p:q]))
      for field,(p,q,convert) in ghcnd_fields)

def mrowtodict(l):
    return dict((field, convert(l[p:q]))
      for field,(p,q,convert) in ghcnm_fields)

def series(uid, element=['TMIN'], file=None, dir=None, scale=True):
    """Load GHCN-D data for station *uid* picking out all
    elements in the list *element*."""

    if file is None:
        file = "%s.dly" % uid
    if dir:
        file = os.path.join(dir, file)

    f = open(file, 'U')
    s = Record(uid=uid, element=element, scale=scale)
    for line in f:
        row = rowtodict(line)
        s.append(row)
    return s

def monthly(f, element=['TMIN', 'TMAX']):
    """Load GHCN-M V3 data for all stations in file *f*.
    Each station is yielded."""
    for uid,rows in itertools.groupby(f, lambda l:l[:11]):
        s = Record(uid=uid, element=element)
        for line in rows:
            row = mrowtodict(line)
            s.append(row)
        yield s

class Station:
    def __init__(self, **k):
        self.__dict__.update(k)

def GHCNDMeta():
    """Return a dict of objects, indexed by the (11-character)
    UID for a station.  The object holds the station
    metadata."""
    # See GHCND readme.txt

    ghcnd_meta = dict(
        uid=        (0,  11, str),
        latitude=   (12, 20, float),
        longitude=  (21, 30, float),
        elevation=  (31, 37, float),
        state=      (38, 40, str),
        name=       (41, 71, str),
        gsnflag=    (72, 75, str),
        hcnflag=    (76, 79, str),
        wmoid=      (80, 85, str),
    ).items()

    r = {}
    for row in open("data/ghcnd-stations.txt"):
        d = {}
        for field,(p,q,convert) in ghcnd_meta:
            d[field] = convert(row[p:q])
        r[d['uid']] = Station(**d)
    return r

def writeGHCNMV3(out, series):
    """To the open file *out* write the series object in
    GHCN-M V3 format."""

    assert len(series.uid) == 11
    # :todo: pick scale according to element.
    scale = 100

    missing_year = [None]*12

    for m in range(0, len(series.data), 12):
        y = series.data[m:m+12]
        # pad to length 12
        y += missing_year[len(y):]
        if y == missing_year:
            # Year with no valid data; do not output.
            continue
        y = [x*100 if x is not None else -9999 for x in y]
        year = series.firstyear + m//12
        out.write("%11s%04d%-4.4s" % (series.uid, year, series.element))
        for x in y:
            out.write("%5.0f   " % x)
        out.write('\n')


def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]
    series(arg[0])

if __name__ == '__main__':
    main()
