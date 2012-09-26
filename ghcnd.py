#!/usr/bin/env python

"""Handle data in GHCN-D format.
See ftp://ftp.ncdc.noaa.goc/pub/data/ghcn/daily/readme.txt for
details of the format (and location of the GHCN-D data).
"""

class Series:
    """When populated, self.data will be a data series for a
    particular element (specified by self.element).
    That value will be a list with one item per month, beginning with
    January of self.firstyear, each month will be a list of values for
    each day.  Missing data will appear as the value *self.MISSING*
    """
    MISSING = -9999
    def __init__(self, **k):
        self.data = []
        self.firstyear = None
        self.element = None
        self.__dict__.update(k)

    def __repr__(self):
        return ("Series(uid=%(uid)r, element=%(element)r, firstyear=%(firstyear)r)" %
          self.__dict__)

    def scale(self):
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
        # For simplicity, we assume that each incoming row can
        # simply be appended.
        offset = 12*(row['year'] - self.firstyear) + row['month'] - 1
        assert offset == len(self.data), "%(uid)s%(year)d%(month)02d gap" % row

        nitems = month_length(row['year'], row['month'])
        m = []
        for i in range(nitems):
            s = row['data'][8*i:8*(i+1)]
            v = s[:5]
            flags = s[5:]
            v = int(v)
            if v != -9999:
                if flags[1] != ' ':
                    v = self.MISSING
                else:
                    v *= self.scale()
            else:
                v = self.MISSING
            m.append(v)
        self.data.append(m)

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
        assert 0, "%d%d month length" % (year, month)
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

def series(uid):
    """Load GHCN-D data for station *uid*."""

    f = open("%s.dly" % uid, 'U')
    s = Series(uid=uid, element='TMIN')
    for line in f:
        row = {}
        for field, (p,q,convert) in ghcnd_fields:
            row[field] = convert(line[p:q])
        s.append(row)
    return s

def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]
    series(arg[0])

if __name__ == '__main__':
    main()
