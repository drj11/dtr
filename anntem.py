#!/usr/bin/env python

"""anntemp.py directory

Compute annual averages for each station's TMIN and TMAX.
A JSON file is written to stdout."""

import json
import os

# Local
import ghcnd

def annual(out, dirname):
    l = {}
    for n in os.listdir(dirname):
        r = {}
        with open(os.path.join(dirname, n)) as f:
            # Only one station per file.
            ss = list(ghcnd.monthly(f))
            if not ss:
                continue
            s, = ss
            r['uid'] = s.uid
            for elem in ['TMIN', 'TMAX']:
                r['annual_average_'+elem] = annual_average(
                  s.series[elem].data)
        l[r['uid']] = r
    json.dump(l, out)

def annual_average(data):
    """Return the average for a value, by computing monthly and
    seasonal and then annual means.  *data* should be a list of
    lists, each inner list being 12 monthly values for a single
    year.  The average is computed as in
    http://data.giss.nasa.gov/gistemp/station_data/seas_ann_means.html
    """

    # Compute mean for each month.
    mmean = [None]*12
    for i,l in enumerate(zip(*data)):
        l = [x for x in l if x is not None]
        if l:
            mmean[i] = sum(l)/float(len(l))

    # Compute mean for each season.
    smean = [None]*4
    for i,season in enumerate([[11,0,1],[2,3,4],[5,6,7],[8,9,10]]):
        l = [mmean[x] for x in season if mmean[x] is not None]
        if l:
            smean[i] = sum(l)/float(len(l))
    if None in smean:
        return None
    return sum(smean)/float(len(smean))

def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]
    annual(sys.stdout, arg[0])

if __name__ == '__main__':
    main()
