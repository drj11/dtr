#!/usr/bin/env python

"""Read a stream containing MDTR and TEXS and show differences
Outputs a GHCN-M V3 style file with element type DMET:

DMET - Diffeerence in Methods (for Diurnal Temperature); calculated
       as TEXS - MDTR.

value '-9999' indicates that TEXS was missing (and hence, so was
MDTR), value ' 8888' indicates that TEXS was present, but MDTR
was missing.
"""

import itertools

# Local
import ghcn

def keep(inp, elems):
    """Retain only (GHCN-M V3) rows with an element in
    the list *elems*."""
    for row in inp:
        if row[15:19] in elems:
            yield row

def diff(inp, out):
    filtered = keep(inp, ['TEXS', 'MDTR'])
    for uidyear,block in itertools.groupby(sorted(filtered), lambda l:l[:15]):
        b = list(block)
        l = ''
        if len(b) == 1:
            row = ghcn.M.rowtodict(b[0])
            assert row['element'] == 'TEXS'
            for i in range(0,96,8):
                d = row['data'][i:i+5]
                if int(d) == -9999:
                    l += '-9999   '
                else:
                    l += ' 8888   '
        else:
            assert len(b) == 2
            row = map(ghcn.M.rowtodict, b)
            row = dict((r['element'], r) for r in row)
            texs = row['TEXS']['data']
            mdtr = row['MDTR']['data']
            for i in range(0,96,8):
                d = texs[i:i+5]
                e = mdtr[i:i+5]
                if (d,e) == ('-9999','-9999'):
                    l += '-9999   '
                elif '-9999' in (d,e):
                    l += ' 8888   '
                else:
                    l += '%5d   ' % (int(d) - int(e))
        out.write('%s%s%s\n' % (uidyear, 'DMET', l))

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
