#!/bin/sh
# sequence
# do everything in sequence.

IFS=''

mkdir -p data

fetch_ghcnd_gsn () {
    if test -e data/ghcnd_gsn.tar.gz
    then
        return
    fi
    (
    cd data
    curl -O ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ghcnd_gsn.tar.gz
    )
}
untar_ghcnd_gsn () {
    if test -d data/ghcnd_gsn
    then
	return
    fi
    (
    cd data
    zcat ghcnd_gsn.tar.gz | tar xvf -
    )
}
sync_dmet () {
    # The work/dmet directory is derived from the data/ghcnd_gsn directory.
    if [ $(ls work/dmet 2>&- |wc -l) -eq $(ls data/ghcnd_gsn 2>&- |wc -l) ]
    then
        return
    fi
    ./massdmet.sh
}
sync_dsumm () {
    # The work/dsumm directory is derived from the work/dmet directory.
    if [ $(ls work/dmet 2>&- |wc -l) -eq $(ls work/dsumm 2>&- |wc -l) ]
    then
        return
    fi
    ./massdsumm.sh
}
sync_dmet_txt () {
    # No check to skip, yet.
    ./summdsumm.py
}

fetch_ghcnd_gsn
untar_ghcnd_gsn
sync_dmet
sync_dsumm
sync_dmet_txt
