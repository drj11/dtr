#!/bin/sh
# plot all stations

IFS=''

mkdir -p work/figure

for f in data/ghcnd_gsn/*.dly
do
    u=$(basename "$f" .dly)
    printf '\r%s' $u
    ./plot.R "$u" TMIN >/dev/null
    ./plot.R "$u" TMAX >/dev/null
done
printf '\n'
