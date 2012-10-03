#!/usr/bin/env python

"""Summarise the dsumm directory."""

import json
import os

def summ():
    os.chdir('dsumm')
    M = 0
    Muid = None
    xbar = 0
    xbaruid = None
    for n in os.listdir('.'):
        j = json.load(open(n))
        if j is None or j['n'] < 120:
            continue
        if abs(j['M']) > abs(M):
            M = abs(j['M'])
            Muid = j['uid']
        if abs(j['xbar']) > abs(xbar):
            xbar = abs(j['xbar'])
            xbaruid = j['uid']
    print 'xbar', xbaruid, xbar
    print 'M', Muid, M

def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]

    summ()

if __name__ == '__main__':
    main()
