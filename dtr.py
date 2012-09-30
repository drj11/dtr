#!/usr/bin/env python

"""Computing DTR - Diurnal Temperature Range.

For output files using GHCN style element codes (TMIN, TMAX, and so on)
we invent:
MDTR - Monthly Mean of Diurnal Temperature Range
TMMM - Temperature Max Minus Min

Note MDTR is computed by first computing DTR for each day (as TMAX - TMIN) then
averaging those for a month.
TMMM is computed first by computing TMIN and TMAX for a month, and
subtracting the two values.
"""

import itertools

# Local
import ghcnd

def two_way_dtr(uid):
    """Load the daly record for station *uid* and return a record object
    with monthly series for MDTR and TMMM (as well as TMIN and TMAX which
    are incidentally required).
    """
    if uid.endswith('.dly'):
        uid = uid.replace('.dly', '')
    rec = ghcnd.series(uid, element=['TMIN', 'TMAX'])
    m = monthly(dtr(rec))
    new = ghcnd.Record(uid=rec.uid,
      element=['TMIN', 'TMAX', 'MDTR', 'TMMM'], firstyear=rec.firstyear)
    new.series['MDTR'] = m
    for elem in ['TMIN', 'TMAX']:
        new.series[elem] = monthly(rec.series[elem])
    new.series['TMMM'] = tmmm(new)

    return new

def tmmm(rec):
    """Given a record with monthly series for TMIN and TMAX, return
    a series for TMMM.
    """

    assert 'TMIN' in rec.series
    assert 'TMAX' in rec.series

    new = ghcnd.Series(uid=rec.uid, element='TMMM', firstyear=rec.firstyear)
    d = []
    for tn,tx in zip(rec.series['TMIN'].data, rec.series['TMAX'].data):
        if None in (tn,tx):
            d.append(None)
        else:
            d.append(tx-tn)
    new.data = d
    return new

def dtr(rec):
    """Convert a record (With TMIN and TMAX series) into a
    series of DTR values, with each month being a sequence
    of daily DTR values.
    """
    new = ghcnd.Series(uid=rec.uid, element='DTR', firstyear=rec.firstyear)
    new.data = [list(single_dtr_month(mn, mx))
      for mn,mx in zip(rec.series['TMIN'].data, rec.series['TMAX'].data)]
    return new

def single_dtr_month(mins, maxs):
    for dn,dx in zip(mins,maxs):
        if None in (dn,dx):
            yield None
        else:
            yield dx-dn

def monthly(daily):
    """Convert a daily series (for example result of dtr())
    to a monthly series."""

    new_elem = daily.element
    if new_elem == 'DTR':
        new_elem = 'MDTR'
    new = ghcnd.Series(uid=daily.uid, element=new_elem, firstyear=daily.firstyear)

    new.data = map(single_monthly_average, daily.data)
    return new

def single_monthly_average(m):
    month = list(m)
    if qa_month(month):
        return monthly_average(month)
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

def monthly_average(month):
    """Convert a sequence of values, in month, to a single average."""

    m = [x for x in month if x is not None]
    assert m
    return float(sum(m))/len(m)

def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]

    rec = two_way_dtr(arg[0])
    ghcnd.writeGHCNMV3(sys.stdout, rec.series['MDTR'])
    ghcnd.writeGHCNMV3(sys.stdout, rec.series['TMMM'])
    ghcnd.writeGHCNMV3(sys.stdout, rec.series['TMIN'])
    ghcnd.writeGHCNMV3(sys.stdout, rec.series['TMAX'])

if __name__ == '__main__':
    main()
