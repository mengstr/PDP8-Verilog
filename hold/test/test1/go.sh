#!/bin/bash

DR="docker run --rm -it -w /root -v/Users/mats/Documents/Projects/PDP8-X/verilog/test/test1/:/root"

FILE=foo
FILES=""
PACKAGE=vq100
PCF=$PACKAGE.pcf


echo --YOSYSING
echo cranphin/icestorm yosys -p "synth_ice40 -top top -json $FILE.json" $FILE.v $FILES
$DR cranphin/icestorm yosys -p "synth_ice40 -top top -json $FILE.json" $FILE.v $FILES > $FILE.yosys.tmp
if [ $? != 0 ]; then cat $FILE.yosys.tmp; exit 1; fi

echo --PLACEING
echo cranphin/icestorm nextpnr-ice40 --ignore-loops --hx1k --package $PACKAGE --pcf $PCF --json $FILE.json --asc $FILE.asc
$DR cranphin/icestorm nextpnr-ice40 --ignore-loops --hx1k --package $PACKAGE --pcf $PCF --json $FILE.json --asc $FILE.asc > $FILE.nextpnr.tmp 
if [ $? != 0 ]; then cat $FILE.nextpnr.tmp; exit 1; fi

echo --PACKING
echo cranphin/icestorm icepack $FILE.asc $FILE.bin
$DR cranphin/icestorm icepack $FILE.asc $FILE.bin
cat $FILE.nextpnr.tmp | sed -ne '/^Info: Device utilisation:/,$ p' | sed '1d' | sed 's/        //g' | sed -n '/^[[:space:]]*$/q;p' | sed 's/Info: //g'
if [ $? != 0 ]; then exit 1; fi

echo --TIMING
echo cranphin/icestorm icetime -d hx1k -P $PACKAGE -p $PCF -m $FILE.asc
$DR cranphin/icestorm icetime -d hx1k -P $PACKAGE -p $PCF -m $FILE.asc | grep 'Timing' | sed 's/\/\/ /        /g'
if [ $? != 0 ]; then exit 1; fi

echo --GRAPHING
$DR cranphin/icestorm yosys -p "prep; show -width -enum -stretch -prefix $FILE -format dot" $FILE.v $FILES > /dev/null
if [ $? != 0 ]; then exit 1; fi

echo --PNGING
$DR cranphin/icestorm dot -Tpng -O $FILE.dot > /dev/null
if [ $? != 0 ]; then exit 1; fi

echo --Done
