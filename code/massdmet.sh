#!/bin/sh

set -e
IFS=''
printf '%s\n' $0

mkdir -p work/dmet
mkdir -p work/mdtr
for f in data/ghcnd_gsn/*.dly
do
    b=$(basename $f)
    u=${b%.dly}
    printf '\r%s' $u
    ./dtr.py $f > work/mdtr/$u
    ./dmet.py < work/mdtr/$u > work/dmet/$u
done
printf '\n'
