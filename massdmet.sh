#!/bin/sh

cd ghcnd_gsn
for f in *.dly
do
    echo $f
    ../dtr.py $f | ../dmet.py > ../dmet/$f
done
