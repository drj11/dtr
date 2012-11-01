#!/usr/bin/env python

"""Summarise the work/dsumm directory.  Output file are written to
work/something."""

import json
import os

# Local
import ghcn

def seqsumm():
    """Yield sequence of summary objects, eliminating those
    that are null, and have fewer than 120 months.
    """
    dir = 'work/dsumm'
    for n in os.listdir(dir):
        j = json.load(open(os.path.join(dir, n)))
        if j is None or j['n'] < 120:
            continue
        yield j

def summ():
    M = 0
    Muid = None
    xbar = 0
    xbaruid = None

    l = list(seqsumm())
    for k in 'xbar', 'M':
        print k
        s = max(l, key=lambda x:abs(x[k]))
        print 'extreme', s['uid'], s[k]
        mean = sum(x[k] for x in l) / float(len(l))
        variance = sum((x[k] - mean)**2 for x in l) / float(len(l))
        print 'mean', mean, 'sd', variance**0.5
        if k == 'M':
            nz = [x for x in l if x[k] != 0]
            print 'non-zero', len(nz), 'zero', len(l)-len(nz)
            mean = sum(x[k] for x in nz) / float(len(nz))
            variance = sum((x[k] - mean)**2 for x in nz) / float(len(nz))
            print '(non-zero)', 'mean', mean, 'sd', variance**0.5
    all_summaries(l)
    eurobox_summaries(l)

def all_summaries(summs):
    with open('work/dmet.txt', 'w') as f:
        summaries_to_file(summs, f)

def summaries_to_file(summs, out):
    """Write out stations summaries to a single file."""
    meta = ghcn.D.meta()
    annual = json.load(open('work/annual.json'))
    for s in summs:
        uid= s['uid']
        m = meta[uid]
        tmin = 'NA' # For compatibility with R
        tmax = 'NA'
        if uid in annual:
            tmin = annual[uid]['annual_average_TMIN']
            tmax = annual[uid]['annual_average_TMAX']
        out.write("%s %s %s %s %s %s %s %s %s\n" % (
          uid, s['M'], s['xbar'],
          m.latitude, m.longitude,
          m.elevation,
          s['n'],
          tmin, tmax))

def eurobox_summaries(summs):
    """As single_file_station_summaries, but restricted to a box
    roughly around northwest europe.
    """
    with open('work/euro.txt', 'w') as f:
        summaries_to_file(stations_in_box(summs, (-15, 15, 38, 70)), f)

def stations_in_box(summs, box):
    meta = ghcn.D.meta()
    w,e,s,n = box
    for summ in summs:
        m = meta[summ['uid']]
        if ((s <= m.latitude < n) and
          (w <= m.longitude < e)):
            yield summ


def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]

    summ()

if __name__ == '__main__':
    main()
