DIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
RUN = docker run --rm -it -w /root -v$(DIR):/root cranphin/icestorm

PROJ = spi2
PIN_DEF = ice40hx1k-evb.pcf
DEVICE = hx1k

all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v
#	$(RUN) verilator --lint-only -Wall $<
	echo ---- RUN YOSYS ----
	$(RUN) yosys -p 'synth_ice40 -top top -blif $@' $< 

%.asc: $(PIN_DEF) %.blif
	echo ---- RUN ARACHNE-PNR ----
	$(RUN) arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -P vq100  -p $^ -o $@ 

%.bin: %.asc
	echo ---- RUN ICEPACK ----
	$(RUN) icepack $< $@

%.rpt: %.asc
	echo ---- RUN ICETIME ----
	$(RUN) icetime -d $(DEVICE) -mtr $@ $<

image: 
	$(RUN) yosys -p "prep; show -stretch -prefix $(PROJ) -format dot" $(PROJ).v
	$(RUN) dot -Tpng $(PROJ).dot -o $(PROJ).png

prog: $(PROJ).bin
	../upload/iceflash /dev/cu.usbmodem48065801 -e -w $< -t -g

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).bin $(PROJ).rpt $(PROJ).dot $(PROJ).png $(PROJ).json

.PHONY: all image prog clean
