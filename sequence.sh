#!/bin/sh
# sequence
# do everything in sequence.

mkdir -p data
if ! test -e data/ghcnd_gsn.tar.gz
then
    (
    cd data
    curl -O ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ghcnd_gsn.tar.gz
    )
fi
if ! test -d data/ghcnd_gsn
then
    (
    cd data
    zcat ghcnd_gsn.tar.gz | tar xvf -
    )
fi
