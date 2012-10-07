#!/bin/sh

IFS=''
printf '%s\n' $0

mkdir -p work/dsumm
for f in work/dmet/*
do
    u=$(basename "$f")
    printf '\r%s' $u
    ./dsumm.py $f > work/dsumm/$u
done
printf '\n'
