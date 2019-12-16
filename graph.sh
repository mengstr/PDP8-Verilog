#!/bin/bash
FILE=$1
TOP=$2
DR="docker run --rm -it -w /root -v/Users/mats/Documents/Projects/PDP8-X/verilog/:/root"
SKIN=netlistsvg.skin
INKSCAPE=/Applications/Inkscape.app/Contents/MacOS/Inkscape

function jsonToPng {
    netlistsvg $1.json -o $1.svg --skin $SKIN
    $INKSCAPE $1.svg --without-gui --export-dpi=150 --export-background=WHITE --export-background-opacity=1.0 --export-type=png --export-file $1.png 2> /dev/null
}

echo Graph as plain
$DR cranphin/icestorm yosys -q -p "prep -top $2; write_json $FILE.plain.json" $FILE.v
jsonToPng $FILE.plain

echo Graph with split wires
$DR cranphin/icestorm yosys -q -p "prep -top $2; splitnets; write_json $FILE.split.json" $FILE.v
jsonToPng $FILE.split

echo Graph Flattened \(logic + black boxes\)
$DR cranphin/icestorm yosys -q -p "prep -top $2 -flatten; write_json $FILE.flat.json" $FILE.v
jsonToPng $FILE.flat

echo Graph into AND and NOT logic
$DR cranphin/icestorm yosys -q -p "prep -top $2 -flatten; cd $2; aigmap; write_json $FILE.aig.json" $FILE.v
jsonToPng $FILE.aig

echo Graph into NAND, AND and NOT logic
$DR cranphin/icestorm yosys -q -p "prep -top $2 -flatten; cd $2; aigmap -nand; write_json $FILE.naig.json" $FILE.v
jsonToPng $FILE.naig

echo Graph into simple logic - NOT, AND, XOR, etc
$DR cranphin/icestorm yosys -q -p "prep -top $2 -flatten; cd $2; simplemap; write_json $FILE.simplemap.json" $FILE.v
jsonToPng $FILE.simplemap
