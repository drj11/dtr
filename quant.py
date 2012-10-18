#!/usr/bin/env python

"""Script to assess whether a data series has been quantised (more coarsely than the 0.1C precision).

The basic idea is:
take first differences of a daily series, and then fit to a n*k model (where n is an integer),
in Hough transform style.  In detail, let d be the first difference.  Add 1 to the point
(n, k) for all integer n and k > 1 and such that n*k = d.  Any k with lots of score is
the quantisation amount.

"""

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
        year_d = [x for x in year_d if x is not None]
        year_d = [abs(p-q) for p,q in zip(year_d, year_d[1:])]
        if not year_d:
          continue
        q_year(year, year_d)

def q_year(year, data):
    # upper limit of quantisation
    U = 13
    # lower limit
    L = 1
    res = [0]*(U+1)
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
