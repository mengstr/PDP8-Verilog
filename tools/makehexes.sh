#!/bin/bash

PAL=tools/palbart
T2H=tools/tape2hexram.sh

\ls -1 hex/src/*.pal | while read fullfile; do
    filename=$(basename -- "$fullfile")
    file="${filename%.*}"
    ext="${filename##*.}"
    echo Assembling $filename
    $PAL -a -r hex/src/$filename
    echo Convering $filename to hex
    $T2H < hex/src/$file.rim > hex/src/$file.hex
    mv -v -f hex/src/$file.hex hex/
    mv -v -f $(\ls -1 hex/src/$file.* | grep -v $filename) hex/tmp/
    echo ------------------------------------------------------------------------------
done

\ls -1 hex/src/*.{pt,PT,bin,BIN,bn,BN} | while read fullfile; do
    filename=$(basename -- "$fullfile")
    file="${filename%.*}"
    ext="${filename##*.}"
    echo Converting $filename to hex
    $T2H < hex/src/$filename > hex/src/$file.hex
    echo ------------------------------------------------------------------------------
done

# Patch initial HLT to be a NOP in Inst1.hex
sed -i '' '103s/f02/e00/' hex/InstTest1-D0AB.hex
