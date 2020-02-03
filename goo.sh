#!/bin/bash

FILE=top
FILES=$(ls [A-Z]*.v)
DR="docker run --rm -it -w/work -v${PWD}/:/work"
PCF=dummy.pcf
PACKAGE=vq100

echo --TESTING
$DR cranphin/iverilog iverilog -g2012 -DNOTRACE -DOSR=$2 -o CPU.vvp CPU.vt $FILES 
if [ $? != 0 ]; then exit 1; fi
$DR cranphin/iverilog vvp CPU.vvp
if [ $? != 0 ]; then exit 1; fi

echo --Done
