#!/usr/bin/env python

"""Summarise the dsumm directory."""

import json
import os

def seqsumm():
    """Yield sequence of summary objects, eliminating those
    that are null, and have fewer than 120 months.
    """
    for n in os.listdir('dsumm'):
        j = json.load(open(os.path.join('dsumm', n)))
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

def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]

    summ()

if __name__ == '__main__':
    main()
