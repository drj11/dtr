#!/usr/bin/env python

"""Summarise DMET files."""

def GHCNMSeries(f):
    from ghcnd import mrowtodict

    # Count of 8888 entries, that is where values appear in
    # TEXS, but not MDTR.
    masked = 0
    # Sum, sum of squares, and number of valid data.
    s = 0.0
    s2 = 0.0
    n = 0
    # Largest (in magnitude) value.
    M = 0

    row = None
    for l in f:
        row = mrowtodict(l)
        for i in range(0,96,8):
            v = int(row['data'][i:i+5])
            if v == -9999:
                pass
            elif v == 8888:
                masked += 1
            else:
                s += v
                s2 += v**2
                n += 1
                if abs(v) > abs(M):
                    M = v

    if n:
        xbar = s/n
        variance = (s2-xbar**2)/n
        sd = variance**0.5
    else:
        xbar = None
        variance = None
        sd = None
        M = None
    if row is None:
        return None
    return dict(uid=row['uid'], s=s, s2=s2, n=n, M=M,
      masked=masked, xbar=xbar, v=variance, sd=sd)


def summ(out, fname):
    import json
    f = open(fname)
    json.dump(GHCNMSeries(f), out)
    

def main(argv=None):
    import sys

    if argv is None:
        argv = sys.argv
    arg = argv[1:]

    summ(sys.stdout, arg[0])

if __name__ == '__main__':
    main()
