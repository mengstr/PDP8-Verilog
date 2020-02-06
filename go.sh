#!/bin/bash

FILE=top
FILES="$(ls [A-Z]*.v)"
echo $FILES
exit
DR="docker run --rm --log-driver=none -a stdout -a stderr -w/work -v${PWD}/:/work"
PCF=dummy.pcf
PACKAGE=vq100
XTAL=100
CLK=25

SKIN=netlistsvg.skin
INKSCAPE=/Applications/Inkscape.app/Contents/MacOS/Inkscape
function jsonToPng {
    netlistsvg $1.json -o $1.svg --skin $SKIN
    $INKSCAPE $1.svg --without-gui --export-dpi=150 --export-background=WHITE --export-background-opacity=1.0 --export-type=png --export-file $1.png 2> /dev/null
    rm $1.svg $1.json
}

function jsonToPng {
    netlistsvg $1.json -o $1.svg --skin $SKIN
    $INKSCAPE $1.svg --without-gui --export-dpi=150 --export-background=WHITE --export-background-opacity=1.0 --export-type=png --export-file $1.png 2> /dev/null
    rm $1.svg $1.json
}

#echo --CREATNG PLL DATA
# PIN15 IOL_7A_GBIN6
#$DR cranphin/icestorm icepll -i $XTAL -o $CLK -q -m -f PLL.v

echo --LINTING
$DR verilator/verilator -Wall -Wno-UNUSED -DNOTOP -DOSR=7777 --top-module top --lint-only top.v $FILES

# if [ $? != 0 ]; then exit 1; fi
# $DR cranphin/iverilog iverilog -i -DNOTOP $FILE.v 
# if [ $? != 0 ]; then exit 1; fi
# if [ -f tb/${FILE}_tb.v ]; then 
#     $DR cranphin/iverilog iverilog -i tb/${FILE}_tb.v;
#     if [ $? != 0 ]; then exit 1; fi
# fi

if [ "$1" != "test" ]; then
    echo --YOSYSING
    $DR cranphin/icestorm yosys -DOSR=7777 -p "synth_ice40 -top top -json $FILE.json" $FILE.v $FILES > $FILE.yosys.tmp
    if [ $? != 0 ]; then echo "err"; cat $FILE.yosys.tmp; exit 1; fi

    echo --PLACEING
    $DR cranphin/icestorm nextpnr-ice40 --freq $CLK --ignore-loops --hx1k --package $PACKAGE --pcf $PCF --json $FILE.json --asc $FILE.asc > $FILE.nextpnr.tmp 2> $FILE.nextpnr.tmp2 
    if [ $? != 0 ]; then cat $FILE.nextpnr.tmp2; exit 1; fi
    cat $FILE.nextpnr.tmp2 | grep "Info: Max frequency for clock"
    cat $FILE.nextpnr.tmp2 | sed -ne '/^Info: Device utilisation:/,$ p' | sed '1d' | sed 's/        //g' | sed -n '/^[[:space:]]*$/q;p' | sed 's/Info: //g'

    echo --TIMING
    $DR cranphin/icestorm icetime -c $CLK -d hx1k -P $PACKAGE -p $PCF -m $FILE.asc > $FILE.icetime.tmp
    cat $FILE.icetime.tmp | grep -A1 'Timing' | sed 's/\/\/ /        /g'
    if [ $? != 0 ]; then exit 1; fi

    # if [ -f "RAM.initial" ] && [ -f "RAM.hex" ]; then
    #     echo --BRAMMING
    #     $DR cranphin/icestorm /bin/sh -c "icebram RAM.initial RAM.hex < $FILE.asc > $FILE.asc2" && mv -f $RAM.asc2 $FILE.asc
    #     if [ $? != 0 ]; then exit 1; fi
    # fi

    echo --PACKING
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
$DR cranphin/iverilog iverilog -g2012 -DTRACE -DOSR=$2 -o CPU.vvp CPU.vt $FILES 
if [ $? != 0 ]; then exit 1; fi
$DR cranphin/iverilog vvp CPU.vvp | ./showop.sh | tee CPU.log
if [ $? != 0 ]; then exit 1; fi

echo --Done
