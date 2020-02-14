PORT:=/dev/cu.usbmodem48065801

# Building for the iCE40HX1K in a VQ100 package on the Olimex board
# having 100 MHz Crystal and target clock at 12.5 MHz
DEVICE 		:= hx1k
PACKAGE 	:= vq100
PCF    		:= olimex-pdp8.pcf
PNRCLKGOAL  := 25

EXTCLK_FREQ	:= 100
EXTCLK_DIV  := 2
CLK_FREQ := $(shell expr \( $(EXTCLK_FREQ) \* 1000000 \) / $(EXTCLK_DIV) )
BAUD		:= 9600
OSR			:= 0000
DEBOUNCECNT	:= 250000 
DEFS		:= 	-DOSR=$(OSR) \
				-DEXTCLK_DIV=$(EXTCLK_DIV) \
				-DCLK_FREQ=$(CLK_FREQ) \
				-DDEBOUNCECNT=$(DEBOUNCECNT) \
				-DBAUD=$(BAUD) 

TARGET 		:= PDP8
SOURCES		:= $(wildcard *.v)
DIR         := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))


DOCKER:=docker run --rm --log-driver=none -a stdout -a stderr -w/work -v$(DIR)/:/work
ICESTORM:=$(DOCKER) cranphin/icestorm
ICARUS:=$(DOCKER) cranphin/iverilog
VERILATOR:=$(DOCKER) --entrypoint /usr/local/bin/verilator verilator/verilator 
ICEFLASH:=../verilog_old/upload/iceflash 


all: $(TARGET).bin report
.PHONY: all report upload lint clean test

$(TARGET).json: $(SOURCES) initialRAM.hex Makefile $(PCF)
	@echo "###"
	@echo "### yosys $(DEFS)"
	@echo "###"
	@$(ICESTORM) yosys \
	$(DEFS) \
	-q \
	-p 'synth_ice40 -top $(TARGET)_top -json $@' \
	$(SOURCES) > yosys.tmp


$(TARGET).asc: $(TARGET).json
	@echo "###"
	@echo "### nextpnr --freq $(PNRCLKGOAL)"
	@echo "###"
	@$(ICESTORM) nextpnr-ice40 \
	--$(DEVICE) \
	--package $(PACKAGE) \
	--pcf $(PCF) \
	--freq $(PNRCLKGOAL) \
	--pcf-allow-unconstrained \
	--json $< \
	--asc $@  2>nextpnr2.tmp 1>nextpnr1.tmp


$(TARGET).bin: $(TARGET).asc
	@echo "###"
	@echo "### icepack"
	@echo "###"
	@$(ICESTORM) icepack \
	$< \
	$@ 2>&1 | tee icepack.tmp


icetime0.tmp: $(TARGET).asc
	@echo "###"
	@echo "### icetime -c $(PNRCLKGOAL)"
	@echo "###"
	@$(ICESTORM) icetime \
	-d $(DEVICE) \
	-c $(PNRCLKGOAL) \
	-m \
	-t \
	-r icetime0.tmp \
	$(TARGET).asc 2>icetime2.tmp 1>icetime1.tmp

report: icetime0.tmp
	@echo ""
	@grep "Device utilisation:" -A6 nextpnr2.tmp | tail -6 | sed "s/Info://g" | cut -c 9-
	@cat icetime1.tmp | grep -A1 'Timing' | sed 's/\/\/ /  /g'
	@echo ""


upload:$(TARGET).bin
	@echo "###"
	@echo "### iceflash $(PORT) -h -e -w $(TARGET).bin -t -G"
	@echo "###"
	@$(ICEFLASH) $(PORT) -h -e -w $(TARGET).bin -t -G
	tio $(PORT) 


lint: $(SOURCES)
	@echo "###"
	@echo "### verilator --lint-only $(DEFS)"
	@echo "###"
	@$(VERILATOR) \
		-Wall \
		-Wno-UNUSED \
		-DNOTOP \
		$(DEFS) \
		--top-module $(TARGET)_top \
		--lint-only \
		$^ 2>&1 | tee lint.tmp


test:
	@echo "###"
	@echo "### iverilog -DOSR=7777 -DCLK_FREQ=4000000 -DBAUD=10000 -DDEBOUNCECNT=10"
	@echo "###"
	@$(ICARUS) iverilog -g2012 \
		-DOSR=7777 -DCLK_FREQ=4000000 -DBAUD=10000 -DDEBOUNCECNT=10 \
		-DTRACE  \
		-o $(TARGET).vvp \
		$(TARGET).vt $(filter-out $(TARGET)_top.v, $(SOURCES))
	$(ICARUS) vvp $(TARGET).vvp | tools/showop.sh | tee test.tmp


clean:
	@rm -f *.{tmp,blif,asc,bin,rpt,dot,png,json,vvp,vcd,svg,out,log}
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