#!/usr/bin/env python

"""Script to assess whether a data series has been quantised (more
coarsely than the 0.1C precision).

The basic idea is:
take first differences of a daily series, and then fit to a n*k
model (where n is an integer), in Hough transform style.  In detail,
let d be the first difference.  Add 1 to the point (n, k) for all
integer n and k > 1 and such that n*k = d.  Any k with lots of
score is the quantisation amount.

We could test each count[k] using R's binom.test (the probably of
"success" for a candidate
quantisation amount is 1/k).

Many stations show quantisation to degrees Fahrenheit, 0.5 C,
1.0 C.  Also, check out the quantisation of SNWD at SZ000002220.

"""

import ghcnd
import math
import itertools

def quant(uid):
    station = ghcnd.series(uid, element=['TMIN', 'TMAX'], dir='data/ghcnd_gsn', scale=False)
    for element,series in station.series.items():
        quant_one_elem(series)
        print uid, element
        for year,data in sorted(series.quantise.items()):
            hist_q_year(year, data)

def quant_one_elem(series):
    """Compute quantisations for each year of the series.
    *Series* is augmented with a .quantise property which
    is a dictionary that maps from year to a count array, a,
    where a[k] gives the counts for the hypothesis that the data
    is quantised to multiples of k."""

    series.quantise = {}
    # Do one year at a time.
    for m in range(0, len(series.data), 12):
        year = series.firstyear + m//12
        year_d = itertools.chain(*series.data[m:m+12])
        year_d = list(year_d)
        year_d = [x for x in year_d if x is not None]
        year_d = [abs(p-q) for p,q in zip(year_d, year_d[1:])]
        if not year_d:
          continue
        series.quantise[year] = q_year(year, year_d)

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
    return res

def hist_q_year(y, l):
    """Histogram of result of q_year."""
    print y
    M = max(*l)
    s = 1
    c = '*'
    if M > 77:
        s = 5
        c = '@'
    for i,k in enumerate(l):
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
