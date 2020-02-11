PORT:=/dev/cu.usbmodem48065801

# Building for the iCE40HX1K in a VQ100 package on the Olimex board
# having 100 MHz Crystal and target clock at 12.5 MHz
DEVICE 		:= hx1k
PACKAGE 	:= vq100
PCF    		:= olimex-pdp8.pcf
PNRCLKGOAL  := 25

EXTCLK_FREQ	:= 100
EXTCLK_DIV  := 2
SYSCLK_FREQ := $(shell expr \( $(EXTCLK_FREQ) \* 1000000 \) / $(EXTCLK_DIV) )

BAUD		:= 9600


TARGET 		:= pdp8
SOURCES		:= $(wildcard *.v)
DIR         := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

DOCKER:=docker run --rm --log-driver=none -a stdout -a stderr -w/work -v$(DIR)/:/work
ICESTORM:=$(DOCKER) cranphin/icestorm
ICARUS:=$(DOCKER) cranphin/iverilog
VERILATOR:=$(DOCKER) --entrypoint /usr/local/bin/verilator verilator/verilator 
ICEFLASH:=../verilog_old/upload/iceflash 


all: $(TARGET).bin time
.PHONY: all upload lint clean

$(TARGET).json: $(SOURCES) RAM.hex Makefile $(PCF)
	$(ICESTORM) yosys \
		-DOSR=0000 \
		-DEXTCLK_DIV=$(EXTCLK_DIV) \
		-DSYSCLK_FREQ=$(SYSCLK_FREQ) \
		-DBAUD=$(BAUD) \
		-q \
		-p 'synth_ice40 -top top -json $@' \
		$(SOURCES) 2>&1 | tee $(TARGET).yosys


$(TARGET).asc: $(TARGET).json
	$(ICESTORM) nextpnr-ice40 \
		-q \
		--$(DEVICE) \
		--package $(PACKAGE) \
		--pcf $(PCF) \
		--freq $(PNRCLKGOAL) \
		--pcf-allow-unconstrained \
		--json $< \
		--asc $@ 2>&1 | tee $(TARGET).nextpnr 
		

$(TARGET).bin: $(TARGET).asc
	@$(ICESTORM) icepack $< $@ 2>&1 | tee $(TARGET).icepack


time:
	@$(ICESTORM) icetime \
		-d $(DEVICE) \
		-c $(PNRCLKGOAL) \
		-m \
		-t \
		-r $(TARGET).icetime \
		$(TARGET).asc 2>&1 > $(TARGET).icetime_
	@cat $(TARGET).icetime_ | grep -A1 'Timing' | sed 's/\/\/ /        /g'


upload:$(TARGET).bin
	@$(ICEFLASH) $(PORT) -h -e -w $(TARGET).bin -t -G
	tio $(PORT) 


lint: $(SOURCES)
	@$(VERILATOR) \
		-Wall \
		-Wno-UNUSED \
		-DNOTOP \
		-DOSR=7777 \
		--top-module top \
		--lint-only \
		$^ 2>&1 | tee $(TARGET).lint


clean:
	@rm -f *.{tmp,tmp2,blif,asc,bin,rpt,dot,png,json,vvp,vcd,svg,out,log,hex}
	@rm -f pdp8.*
	@rm -f .*_history
	@rm -f *~


#
# @echo "verilator --top-module $(basename $@) --lint-only $<"
# @$(VERILATOR) /bin/sh -c "verilator -DNOTOP --top-module $(basename $@) --lint-only $<"
#
# TARGET=CLORIN
# image:
# 	@$(ICESTORM) yosys -p "prep; show -stretch -prefix $(TARGET) -format dot" $(TARGET).v > /dev/null
# 	@$(ICESTORM) dot -Tpng -O $(TARGET).dot > a.a
#
# tb:
# 	@$(ICARUS) iverilog -DTB -o $(TARGET).vvp $(TARGET).v $(TARGET)_tb.v
# 	@$(ICARUS) vvp $(TARGET).vvp
#
#	@echo icetime -d $(DEVICE) -mtr $@ $<
#	@cat $(basename $@).tmp | /usr/bin/sed -ne '/^Info: Device utilisation:/,$$ p' | /usr/bin/sed -n '/^[[:space:]]*$$/q;p' | sed 's/Info: //g'
#	@$(ICESTORM) icetime -d $(DEVICE) -mtr $@ $< | grep 'Timing' | sed 's/\/\/ //g'
#