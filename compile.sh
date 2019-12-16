#!/bin/bash

FILE=$1
DR="docker run --rm -it -w /root -v/Users/mats/Documents/Projects/PDP8-X/verilog/:/root"
PCF=dummy.pcf
PACKAGE=vq100

if [ "$2" != "tb" ]; then

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
    $DR cranphin/icestorm yosys -q -p "synth_ice40 -top top -json $FILE.json" $FILE.v
    if [ $? != 0 ]; then exit 1; fi

    echo --PLACEING
    $DR cranphin/icestorm nextpnr-ice40 --ignore-loops --hx1k --package $PACKAGE --pcf $PCF --json $FILE.json --asc $FILE.asc > $FILE.tmp || { cat $FILE.tmp; exit 1; }
    if [ $? != 0 ]; then exit 1; fi

    if [ -f "$FILE.ihex" ] && [ -f "$FILE.hex" ]; then
        echo --BRAMMING
        $DR cranphin/icestorm /bin/sh -c "icebram $FILE.ihex $FILE.hex < $FILE.asc > $FILE.asc2" && mv -f $FILE.asc2 $FILE.asc
        if [ $? != 0 ]; then exit 1; fi
    fi

    echo --PACKING
    $DR cranphin/icestorm icepack $FILE.asc $FILE.bin
    cat $FILE.tmp | sed -ne '/^Info: Device utilisation:/,$ p' | sed '1d' | sed 's/        //g' | sed -n '/^[[:space:]]*$/q;p' | sed 's/Info: //g'
    if [ $? != 0 ]; then exit 1; fi

    echo --TIMING
    $DR cranphin/icestorm icetime -d hx1k -P $PACKAGE -p $PCF -m $FILE.asc | grep 'Timing' | sed 's/\/\/ /        /g'
    if [ $? != 0 ]; then exit 1; fi

    echo --GRAPHING
    $DR cranphin/icestorm yosys -p "prep; show -width -enum -stretch -prefix $FILE -format dot" $FILE.v > /dev/null
    if [ $? != 0 ]; then exit 1; fi

    echo --PNGING
    $DR cranphin/icestorm dot -Tpng -O $FILE.dot > /dev/null
    if [ $? != 0 ]; then exit 1; fi
fi

if [ "$2" == "up" ]; then
    ./upload/iceflash /dev/cu.usbmodem48065801 -h -e -w $FILE.bin -g
#    tio /dev/cu.usbmodem48065801 
    exit 0;
fi

if [ -f tb/${FILE}_tb.v ]; then 
    echo --TESTING
    $DR cranphin/iverilog iverilog -DTB -o $FILE.vvp $FILE.v tb/${FILE}_tb.v
    if [ $? != 0 ]; then exit 1; fi
    $DR cranphin/iverilog vvp $FILE.vvp
    if [ $? != 0 ]; then exit 1; fi
fi
