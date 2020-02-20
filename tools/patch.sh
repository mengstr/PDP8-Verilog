#!/bin/bash

addrOct=$1
oldDataOct=$2
newDataOct=$3

addrDec=$(printf "%d" 0$addrOct)
oldDataHex=$(printf "%03x" 0$oldDataOct)
newDataHex=$(printf "%03x" 0$newDataOct)

foundHex=$(head -$(($addrDec+1)) initialRAM.hex | tail -1)
if [ "$oldDataHex" != "$foundHex" ]
then 
    >&2 echo "Error patching: Expected hex $oldDataHex at location octal $addrOct but found hex $foundHex"
    exit 1
fi

echo ="$(head -$(($addrDec)) initialRAM.hex)"
echo $newDataHex
echo ="$(tail -$((4095-$addrDec)) initialRAM.hex)"

