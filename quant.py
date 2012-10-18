#!/usr/bin/env python

"""Script to assess whether a data series has been quantised (more coarsely than the 0.1C precision)."""

import ghcnd
import math
import itertools

def quant(uid):
    station = ghcnd.series(uid, element=['TMIN'], dir='data/ghcnd_gsn', scale=False)
    for element,series in station.series.items():
        quant_one_elem(series)

def quant_one_elem(series):
    """Identify the quantisation in each year of the series."""

    # Do one year at a time.
    for m in range(0, len(series.data), 12):
        year = series.firstyear + m//12
        year_d = itertools.chain(*series.data[m:m+12])
        year_d = list(year_d)
        assert len(year_d) in [365,366]
        year_d = [x for x in year_d if x is not None]
        year_d = [abs(p-q) for p,q in zip(year_d, year_d[1:])]
        if not year_d:
          continue
        q_year(year, year_d)

def q_year(year, data):
    # upper limit of quantisation
    U = 11
    # lower limit
    L = 1
    res = [0]*12
    for x in data:
        x = float(x)
        for n in range(max(1, int(math.floor(x/U))), int(math.ceil(x/L) + 1)):
            k = int(round(x/n))
            if k*n == x and k < len(res):
                res[k] += 1
    print year
    M = max(*res)
    s = 1
    c = '*'
    if M > 77:
        s = 5
        c = '@'
    for i,k in enumerate(res):
        if i == 0:
            continue
        print "%02d" % i, c * (k//s)

def main(argv=None):
    import sys

    if argv is None:
        argv = sys.argv
    arg = argv[1:]
    quant(arg[0])

if __name__ == '__main__':
    main()
