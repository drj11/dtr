#!/bin/sh

cd dmet
for f in *.dly
do
    echo $f
    g=${f%.dly}
    ../dsumm.py $f > ../dsumm/$g
done
