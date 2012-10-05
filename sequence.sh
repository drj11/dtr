#!/bin/sh
# sequence
# do everything in sequence.

IFS=''

sync_dmet () {
    # The work/dmet directory is derived from the data/ghcnd_gsn directory.
    if [ $(ls work/dmet|wc -l) -eq $(ls data/ghcnd_gsn|wc -l) ]
    then
        return
    fi
    ./massdmet.sh
}

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
sync_dmet
