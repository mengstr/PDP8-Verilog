#!/bin/bash

FILE=top
FILES=$(ls [A-Z]*.v)
DR="docker run --rm --log-driver=none -a stdout -a stderr -w/work -v${PWD}/:/work"
PCF=dummy.pcf
PACKAGE=vq100

echo --LINTING
$DR verilator/verilator -Wall -Wno-UNUSED -DNOTOP --top-module top --lint-only top.v $FILES

# if [ $? != 0 ]; then exit 1; fi
# $DR cranphin/iverilog iverilog -i -DNOTOP $FILE.v 
# if [ $? != 0 ]; then exit 1; fi
# if [ -f tb/${FILE}_tb.v ]; then 
#     $DR cranphin/iverilog iverilog -i tb/${FILE}_tb.v;
#     if [ $? != 0 ]; then exit 1; fi
# fi

if [ "$1" != "test" ]; then

    echo --YOSYSING
    echo cranphin/icestorm yosys -p "synth_ice40 -top top -json $FILE.json" $FILE.v $FILES
    $DR cranphin/icestorm yosys -p "synth_ice40 -top top -json $FILE.json" $FILE.v $FILES > $FILE.yosys.tmp
    if [ $? != 0 ]; then cat $FILE.yosys.tmp; exit 1; fi

    echo --PLACEING
    echo cranphin/icestorm nextpnr-ice40 --ignore-loops --hx1k --package $PACKAGE --pcf $PCF --json $FILE.json --asc $FILE.asc
    $DR cranphin/icestorm nextpnr-ice40 --ignore-loops --hx1k --package $PACKAGE --pcf $PCF --json $FILE.json --asc $FILE.asc > $FILE.nextpnr.tmp 2> $FILE.nextpnr.tmp2 
    if [ $? != 0 ]; then cat $FILE.nextpnr.tmp; exit 1; fi
    cat $FILE.nextpnr.tmp2 | sed -ne '/^Info: Device utilisation:/,$ p' | sed '1d' | sed 's/        //g' | sed -n '/^[[:space:]]*$/q;p' | sed 's/Info: //g'

    echo --TIMING
    echo cranphin/icestorm icetime -d hx1k -P $PACKAGE -p $PCF -m $FILE.asc
    $DR cranphin/icestorm icetime -d hx1k -P $PACKAGE -p $PCF -m $FILE.asc | grep 'Timing' | sed 's/\/\/ /        /g'
    if [ $? != 0 ]; then exit 1; fi

    # if [ -f "RAM.initial" ] && [ -f "RAM.hex" ]; then
    #     echo --BRAMMING
    #     $DR cranphin/icestorm /bin/sh -c "icebram RAM.initial RAM.hex < $FILE.asc > $FILE.asc2" && mv -f $RAM.asc2 $FILE.asc
    #     if [ $? != 0 ]; then exit 1; fi
    # fi

    echo --PACKING
    echo cranphin/icestorm icepack $FILE.asc $FILE.bin
    $DR cranphin/icestorm icepack $FILE.asc $FILE.bin
    if [ $? != 0 ]; then exit 1; fi


    if false; then 
        echo --GRAPHING
        $DR cranphin/icestorm yosys -p "prep; show -width -enum -stretch -prefix $FILE -format dot" $FILE.v $FILES > /dev/null
        if [ $? != 0 ]; then exit 1; fi

        echo --PNGING
        $DR cranphin/icestorm dot -Tpng -O $FILE.dot > /dev/null
        if [ $? != 0 ]; then exit 1; fi
    fi # 'false'

    if [ "$1" == "up" ]; then
        ./upload/iceflash /dev/cu.usbmodem48065801 -h -e -w $FILE.bin -g
        tio /dev/cu.usbmodem48065801 
        exit 0;
    fi

fi # !=test

echo --TESTING
$DR cranphin/iverilog iverilog -D TRACE -o CPU.vvp CPU.vt $FILES 
if [ $? != 0 ]; then exit 1; fi
$DR cranphin/iverilog vvp CPU.vvp | ./showop.sh | tee CPU.log
if [ $? != 0 ]; then exit 1; fi

echo --Done
