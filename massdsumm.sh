#!/bin/sh

mkdir -p work/dsumm
for f in work/dmet/*
do
    u=$(basename "$f")
    echo $u
    ./dsumm.py $f > work/dsumm/$u
done
