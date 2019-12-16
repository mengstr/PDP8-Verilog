#!/bin/bash 
docker run --rm -it -w /root -v/Users/mats/Documents/Projects/PDP8-X/verilog/:/root  cranphin/iverilog iverilog -g2012 -o ttl_$1.vvp tb.v ttl_$1.v ttl_$1_tb.v
docker run --rm -it -w /root -v/Users/mats/Documents/Projects/PDP8-X/verilog/:/root  cranphin/iverilog vvp ttl_$1.vvp

