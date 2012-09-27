#!/usr/bin/env python

"""Computing DTR - Diurnal Temperature Range."""

import itertools

# Local
import ghcnd

def dtr(uid):
    """Convert a record (With TMIN and TMAX series) into a
    series of DTR values, with each month being a sequence
    of daily DTR values.
    """
    rec = ghcnd.series(uid, element=['TMIN', 'TMAX'])
    new = ghcnd.Series(uid=uid, element='DTR', firstyear=rec.firstyear)
    new.data = [list(single_dtr_month(rec, mn, mx))
      for mn,mx in zip(rec.series['TMIN'].data, rec.series['TMAX'].data)]
    return new

def single_dtr_month(rec, mins, maxs):
    for dn,dx in zip(mins,maxs):
        if dn != rec.MISSING and dx != rec.MISSING:
            yield dx-dn
        else:
            yield None

def dtr_m(daily):
    """Convert result of dtr() to a monthly series."""

    assert daily.element == 'DTR'
    new = ghcnd.Series(uid=daily.uid, element='MDTR', firstyear=daily.firstyear)

    new.data = map(single_dtr_average, daily.data)
    return new

def single_dtr_average(m):
    month = list(m)
    if qa_month(month):
        return dtr_average(month)
    else:
        return None

def qa_month(month):
    """Given a Month's worth of daily DTR data, retturn true if
    it is satsifactory, return false otherwise.  We check that:
    there is no missing gap longer that 2 records; and,
    the total number of missing days is < 10.
    """

    missing = 0
    for isgap,block in itertools.groupby(month, lambda x:x is None):
        if isgap:
            b = list(block)
            if len(b) > 2:
                return False
            missing += len(b)
    if missing < 10:
        return True
    return False

def dtr_average(month):
    """Convert a sequence of values, in month, to a single
    average."""

    m = [x for x in month if x is not None]
    assert m
    return float(sum(m))/len(m)

def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]

    m = dtr_m(dtr(arg[0]))
    print m
    print m.data

if __name__ == '__main__':
    main()
