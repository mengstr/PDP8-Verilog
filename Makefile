# Current directory
DIR:=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
# Start docker and map to current directory
DOCKER:=docker run --rm -it -w /root -v$(DIR):/root
# Run container having yosys, nextptr, icepack and icetime
ICESTORM:=$(DOCKER) cranphin/icestorm
# Run container having iverilog
ICARUS:=$(DOCKER) cranphin/iverilog
# Run container having verilator
VERILATOR:=$(DOCKER) antonkrug/verilator-slim

# Building for the iCE40HX1K...
DEVICE 		:= hx1k
# ...in a VQ100 package 
PACKAGE 	:= vq100

# all: CLORIN.v
# IOT-BASE-DECODER.v
# IR-DECODER.v
# OPR-DECODER.v
# PROGRAMCOUNTER.v
# ROTATER.v
# SKIP.v
# tb.v


SOURCES		:=	$(wildcard *.v)
BINS		:= 	$(SOURCES:.v=.bin)

all: $(BINS)

%.json: %.v
	@echo "verilator --top-module $(basename $@) --lint-only $<"
	@$(VERILATOR) /bin/sh -c "verilator -DNOTOP --top-module $(basename $@) --lint-only $<"
	@echo yosys -top top -json $@ $<
	@$(ICESTORM) yosys -q -p 'synth_ice40 -top top -json $@' $<

%.asc: %.json
	@echo nextpnr --pcf top.pcf --json $< --asc $@
	@$(ICESTORM) nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf dummy.pcf --json $< --asc $@ > $(basename $@).tmp || { cat $(basename $@).tmp; exit 1; }

%.bin: %.asc
	@echo icepack $< $@
	@$(ICESTORM) icepack $< $@
#	@echo icetime -d $(DEVICE) -mtr $@ $<
#	@cat $(basename $@).tmp | /usr/bin/sed -ne '/^Info: Device utilisation:/,$$ p' | /usr/bin/sed -n '/^[[:space:]]*$$/q;p' | sed 's/Info: //g'
#	@$(ICESTORM) icetime -d $(DEVICE) -mtr $@ $< | grep 'Timing' | sed 's/\/\/ //g'

#%.rpt: %.asc
# 	@$(ICESTORM) icetime -d $(DEVICE) -mtr $@ $<
# 	@cat $(PROJ).tmp | /usr/bin/sed -ne '/^Info: Device utilisation:/,$$ p' | /usr/bin/sed -n '/^[[:space:]]*$$/q;p'

PROJ=CLORIN
image:
	@$(ICESTORM) yosys -p "prep; show -stretch -prefix $(PROJ) -format dot" $(PROJ).v > /dev/null
	@$(ICESTORM) dot -Tpng -O $(PROJ).dot > a.a

# prog: $(PROJ).bin
# 	@../upload/iceflash /dev/cu.usbmodem48065801 -e -w $< -t -g

# tb:
# 	@$(ICARUS) iverilog -DTB -o $(PROJ).vvp $(PROJ).v $(PROJ)_tb.v
# 	@$(ICARUS) vvp $(PROJ).vvp

#lint:
#	@$(VERILATOR) /bin/sh -c "verilator --top-module $(PROJ) --lint-only $(PROJ).v"

clean:
	@rm -f *.{tmp,blif,asc,bin,rpt,dot,png,json,vvp,vcd}




# .PHONY: all image prog tb lint clean

