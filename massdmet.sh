#!/bin/sh

mkdir -p work/dmet
cd data/ghcnd_gsn
for f in *.dly
do
    u=${f%.dly}
    echo $u
    ../../dtr.py $f | ../../dmet.py > ../../work/dmet/$u
done
