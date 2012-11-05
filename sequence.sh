#!/bin/sh
# sequence
# do everything in sequence.

set -e
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

dirs_eq () {
    # Check that directories $1 and $2 contain the same number
    # of files.  Possibly we could do something more
    # sophisticated here, but one complication is that when
    # checking ghcnd_gsn and dmet we rely on different filenames
    # (all the ghcnd_gsn files end in .dly).
    # Return true if so.
    test $(ls $1 2>&- | wc -l) = $(ls $2 2>&- | wc -l)
}

fetch () {
    # Fetch $1 into data/$(basename $1) if and only if it isn't
    # already there.
    destination=$(basename "$1")
    if test -e "data/$destination"
    then
        return
    fi
    curl "$1" > "data/$destination"
}

make_links () {
    if ! test -d ../http
    then
        return
    fi
    (
    cd ../http
    for a in ../git/work/*.png
    do
        ln -f -s $a
    done
    )
}

fetch_ghcnd_gsn () {
    fetch ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ghcnd_gsn.tar.gz
}
fetch_ghcnd_meta () {
    fetch ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.txt
    fetch ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ghcnd-countries.txt
}
fetch_ghcnd_readme () {
    fetch ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt
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
make_dmet () {
    # The work/dmet directory is derived from the data/ghcnd_gsn
    # directory.
    if dirs_eq work/dmet data/ghcnd_gsn
    then
        return
    fi
    ./massdmet.sh
}
concat_dmet () {
    f=$(ls -t work/dmet)
    if newer work/dmet.ghcnv3 "$f"
    then
      return
    fi
    cat work/dmet/* > work/dmet.ghcnv3
}
make_annual () {
    if newer work/annual.json work/mdtr &&
      newer work/annual.json anntem.py
    then
        return
    fi
    ./anntem.py work/mdtr > work/annual.json
}
sync_dsumm () {
    # The work/dsumm directory is derived from the work/dmet directory.
    if dirs_eq work/dmet work/dsumm
    then
        return
    fi
    ./dmetsumm.sh
}
sync_dmet_txt () {
    if newer work/dmet.txt work/dsumm &&
      newer work/dmet.txt summdsumm.py &&
      newer work/dmet.txt work/annual.json
    then
        return
    fi
    ./summdsumm.py
}
make_station_dmet_png () {
    if newer work/station-dmet.png work/dmet.txt &&
      newer work/station-dmet.png fig-mass.R
    then
        return
    fi
    ./fig-mass.R
}

fetch_ghcnd_gsn
untar_ghcnd_gsn
fetch_ghcnd_meta
fetch_ghcnd_readme
make_dmet
concat_dmet
make_annual
sync_dsumm
sync_dmet_txt &&
make_station_dmet_png
make_links
