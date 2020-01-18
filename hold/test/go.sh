#!/bin/bash

DR="docker run --rm -it -w /root -v/Users/mats/Documents/Projects/PDP8-X/verilog/test/:/root"

FILE=CPU
FILES=""
PACKAGE=vq100
PCF=$PACKAGE.pcf


# echo --LINTING
# $DR antonkrug/verilator-slim /bin/sh -c "verilator -Wall -DNOTOP --top-module $FILE --lint-only $FILE.v"
# if [ $? != 0 ]; then exit 1; fi
# $DR cranphin/iverilog iverilog -i -DNOTOP $FILE.v 
# if [ $? != 0 ]; then exit 1; fi
# if [ -f tb/${FILE}_tb.v ]; then 
#     $DR cranphin/iverilog iverilog -i tb/${FILE}_tb.v;
#     if [ $? != 0 ]; then exit 1; fi
# fi


echo --YOSYSING
echo cranphin/icestorm yosys -p "synth_ice40 -top top -json $FILE.json" $FILE.v $FILES
$DR cranphin/icestorm yosys -p "synth_ice40 -top top -json $FILE.json" $FILE.v $FILES > $FILE.yosys.tmp
if [ $? != 0 ]; then cat $FILE.yosys.tmp; exit 1; fi

echo --PLACEING
echo cranphin/icestorm nextpnr-ice40 --ignore-loops --hx1k --package $PACKAGE --pcf $PCF --json $FILE.json --asc $FILE.asc
$DR cranphin/icestorm nextpnr-ice40 --ignore-loops --hx1k --package $PACKAGE --pcf $PCF --json $FILE.json --asc $FILE.asc > $FILE.nextpnr.tmp 
if [ $? != 0 ]; then cat $FILE.nextpnr.tmp; exit 1; fi

# if [ -f "RAM.initial" ] && [ -f "RAM.hex" ]; then
#     echo --BRAMMING
#     $DR cranphin/icestorm /bin/sh -c "icebram RAM.initial RAM.hex < $FILE.asc > $FILE.asc2" && mv -f $RAM.asc2 $FILE.asc
#     if [ $? != 0 ]; then exit 1; fi
# fi

echo --PACKING
echo cranphin/icestorm icepack $FILE.asc $FILE.bin
$DR cranphin/icestorm icepack $FILE.asc $FILE.bin
cat $FILE.nextpnr.tmp | sed -ne '/^Info: Device utilisation:/,$ p' | sed '1d' | sed 's/        //g' | sed -n '/^[[:space:]]*$/q;p' | sed 's/Info: //g'
if [ $? != 0 ]; then exit 1; fi

echo --TIMING
echo cranphin/icestorm icetime -d hx1k -P $PACKAGE -p $PCF -m $FILE.asc
$DR cranphin/icestorm icetime -d hx1k -P $PACKAGE -p $PCF -m $FILE.asc | grep 'Timing' | sed 's/\/\/ /        /g'
if [ $? != 0 ]; then exit 1; fi

#if false; then 

echo --GRAPHING
$DR cranphin/icestorm yosys -p "prep; show -width -enum -stretch -prefix $FILE -format dot" $FILE.v $FILES > /dev/null
if [ $? != 0 ]; then exit 1; fi

echo --PNGING
$DR cranphin/icestorm dot -Tpng -O $FILE.dot > /dev/null
if [ $? != 0 ]; then exit 1; fi

#fi # 'false'

# if [ "$2" == "up" ]; then
#     ./upload/iceflash /dev/cu.usbmodem48065801 -h -e -w $FILE.bin -g
#     tio /dev/cu.usbmodem48065801 
#     exit 0;
# fi


if [ -f tb/CPU_tb.v ]; then 
    echo --TESTING
    echo $DR cranphin/iverilog iverilog -DTB -o $FILE.vvp $FILE.v $FILES tb/${FILE}_tb.v
    $DR cranphin/iverilog iverilog -DTB -o $FILE.vvp $FILE.v $FILES tb/${FILE}_tb.v
    if [ $? != 0 ]; then exit 1; fi
    echo $DR cranphin/iverilog vvp $FILE.vvp
    $DR cranphin/iverilog vvp $FILE.vvp
    if [ $? != 0 ]; then exit 1; fi
fi

echo --Done
