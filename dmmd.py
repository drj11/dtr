#!/usr/bin/env python

"""Read a stream containg MDTR and TMMM and show when they are
different for any year.  Outputs a GHCN-M V3 style file with
element type DMMD:

DMMD - Diurnal Method Monthly Difference (TMMM - MDTR)

value '-9999' indicates that TMMM was missing (and hence, so was
MDTR), value ' 8888' indicates that TMMM was present, but MDTR
was missing.
"""

import itertools

# Local
import ghcnd

def diff(inp, out):
    for uidyear,block in itertools.groupby(sorted(inp), lambda l:l[:15]):
        b = list(block)
        l = ''
        if len(b) == 1:
            row = ghcnd.mrowtodict(b[0])
            assert row['element'] == 'TMMM'
            for i in range(0,96,8):
                d = row['data'][i:i+5]
                if int(d) == -9999:
                    l += '-9999   '
                else:
                    l += ' 8888   '
        else:
            assert len(b) == 2
            row = map(ghcnd.mrowtodict, b)
            row = dict((r['element'], r) for r in row)
            tmmm = row['TMMM']['data']
            mdtr = row['MDTR']['data']
            for i in range(0,96,8):
                d = tmmm[i:i+5]
                e = mdtr[i:i+5]
                if (d,e) == ('-9999','-9999'):
                    l += '-9999   '
                elif '-9999' in (d,e):
                    l += ' 8888   '
                else:
                    l += '%5d   ' % (int(d) - int(e))
        out.write('%s%s%s\n' % (uidyear, 'DMMD', l))

def main(argv=None):
    import sys
    if argv is None:
        argv = sys.argv
    arg = argv[1:]

    if arg:
        arg = map(open, arg)
    else:
        arg = [sys.stdin]
    for a in arg:
        diff(a, sys.stdout)

if __name__ == '__main__':
    main()
