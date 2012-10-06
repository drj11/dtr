#!/bin/sh
# sequence
# do everything in sequence.

IFS=''

mkdir -p data

newer () {
    # true (exit status 0) when first argument is newer than second argument.
    # false (exit status 1) otherwise.
    # :todo: should probably do some error checking, like when $1 and $2
    # are not files.
    if [ "$(find "$1" -newer "$2" 2>&- )" ]
    then
        return 0
    fi
    return 1
}

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
    if newer work/dmet.txt work/dsumm
    then
        return
    fi
    ./summdsumm.py
}

fetch_ghcnd_gsn
untar_ghcnd_gsn
sync_dmet
sync_dsumm
sync_dmet_txt
