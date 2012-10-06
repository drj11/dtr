#!/usr/bin/env python

"""Summarise the work/dsumm directory."""

import json
import os

# Local
import ghcnd

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
    single_file_station_summaries(l)

def single_file_station_summaries(summs):
    """Write out stations summaries in a single file."""
    meta = ghcnd.GHCNDMeta()
    with open('work/dmet.txt', 'w') as d:
        for s in summs:
            uid= s['uid']
            m = meta[uid]
            d.write("%s %s %s %s %s %s %s\n" % (
              uid, s['M'], s['xbar'],
              m.latitude, m.longitude,
              m.elevation,
              s['n']))

def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]

    summ()

if __name__ == '__main__':
    main()
