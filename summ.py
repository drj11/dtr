#!/usr/bin/env python

"""summ.py STATIONID ELEM"""

import sys
# Local
import ghcn

def summarise(out, uid, element=['TMIN', 'TMAX']):
    sys.stdout.write("%s %r\n" % (uid, element))
    rec = ghcn.D.load(uid, element, dir='data/ghcnd_gsn')
    sys.stdout.write("first year: %s\n" % rec.firstyear)
    for elem in element:
        sys.stdout.write("%s\n" % elem)
        s = rec.series[elem]
        years = len(s.data)/12.0
        if int(years) == years:
            years = int(years)
        sys.stdout.write("years: %r\n" % years)
        missing = 0
        for m in s.data:
            for v in m:
                missing += v is None
        sys.stdout.write("missing days: %d\n" % missing)
    if 'TMIN' in element and 'TMAX' in element:
        min_missing = 0
        max_missing = 0
        for mn,mx in zip(rec.series['TMIN'].data, rec.series['TMAX'].data):
            for vn,vx in zip(mn,mx):
                if vn is None and vx is not None:
                    min_missing += 1
                if vx is None and vn is not None:
                    max_missing += 1
        sys.stdout.write("TMIN missing, TMAX present: %d\n" % min_missing)
        sys.stdout.write("TMAX missing, TMIN present: %d\n" % max_missing)

def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]

    summarise(sys.stdout, arg[0])

if __name__ == '__main__':
    main()
