#!/usr/bin/env python

"""Computing DTR."""

import itertools

# Local
import ghcnd

def dtr(uid):
    """Convert a record (With TMIN and TMAX series) into a
    sequence of DTR values, which each month yielded being a
    of daily DTR values.
    """
    rec = ghcnd.series(uid, element=['TMIN', 'TMAX'])
    for mn,mx in zip(rec.series['TMIN'].data, rec.series['TMAX'].data):
        yield single_dtr_month(rec, mn, mx)

def single_dtr_month(rec, mins, maxs):
    for dn,dx in zip(mins,maxs):
        if dn != rec.MISSING and dx != rec.MISSING:
            yield dx-dn
        else:
            yield None

def dtr_m(daily):
    """Convert result of dtr() to sequence of monthly averages."""
    for imonth in daily:
        month = list(imonth)
        if qa_month(month):
            yield dtr_average(month)
        else:
            yield None

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
    return sum(m)/len(m)

def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]

    print list(dtr_m(dtr(arg[0])))

if __name__ == '__main__':
    main()
