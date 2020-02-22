PORT:=/dev/cu.usbmodem48065801

# Building for the iCE40HX1K in a VQ100 package on the Olimex board
# having 100 MHz Crystal and target clock at 12.5 MHz
DEVICE 		:= hx1k
PACKAGE 	:= vq100
PCF    		:= olimex-pdp8.pcf
PNRCLKGOAL  := 25

OSR			:= 0000
DEFS		:= 	-DOSR=$(OSR) 

TARGET 		:= PDP8
SOURCES		:= $(wildcard *.v)
DIR         := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

DOCKER:=docker run --rm --log-driver=none -a stdout -a stderr -w/work -v$(DIR)/:/work
ICESTORM:=$(DOCKER) cranphin/icestorm
ICARUS:=$(DOCKER) cranphin/iverilog
VERILATOR:=$(DOCKER) --entrypoint /usr/local/bin/verilator verilator/verilator 
ICEFLASH:=../verilog_old/upload/iceflash 

rev=$$(tput bold)
norm=$$(tput sgr0)

all: $(TARGET).bin report
.PHONY: all report upload lint clean test

$(TARGET).json: $(SOURCES) initialRAM.hex Makefile $(PCF)
	@echo "${rev}###  yosys $(DEFS) ###${norm}"
	@$(ICESTORM) yosys \
	  $(DEFS) \
	  -q \
	  -p 'synth_ice40 -top $(TARGET)_top -json $@'  \
	  $(SOURCES) > yosys.tmp


$(TARGET).asc: $(TARGET).json
	@echo "${rev}###  nextpnr --freq $(PNRCLKGOAL) ###${norm}"
	@$(ICESTORM) nextpnr-ice40 \
	--$(DEVICE) \
	--package $(PACKAGE) \
	--pcf $(PCF) \
	--freq $(PNRCLKGOAL) \
	--pcf-allow-unconstrained \
	--json $< \
	--asc $@  2>nextpnr2.tmp 1>nextpnr1.tmp


$(TARGET).bin: $(TARGET).asc
	@echo "${rev}###  icepack ###${norm}"
	@$(ICESTORM) icepack \
	$< \
	$@ 2>&1 | tee icepack.tmp


icetime0.tmp: $(TARGET).asc
	@echo "${rev}###  icetime -c $(PNRCLKGOAL) ###${norm}"
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
	@echo "${rev}###  iceflash $(PORT) -h -e -w $(TARGET).bin -t -G ###${norm}"
	@$(ICEFLASH) $(PORT) -h -e -w $(TARGET).bin -t -G
	tio $(PORT) 


lint: $(SOURCES)
	@echo "${rev}###  verilator --lint-only $(DEFS) ###${norm}"
	@$(VERILATOR) \
		-Wall \
		-Wno-UNUSED \
		-DNOTOP \
		$(DEFS) \
		--top-module $(TARGET)_top \
		--lint-only \
		$^ 2>&1 | tee lint.tmp

CNT:=100000
OSR:=0000
BP:=7777
TRACE:=

test:
	@echo "${rev}###  iverilog -DOSR=$(OSR) -DCNT=$(CNT) -DBP=$(BP) -D$(TRACE)TRACE  ###${norm}"
	@$(ICARUS) iverilog -g2012 \
		-DIVERILOG \
		-DOSR=$(OSR) \
		-DBP=$(BP) \
		-D$(TRACE)TRACE \
		-DCNT=$(CNT) \
		-o $(TARGET).vvp \
		$(TARGET).vt $(filter-out $(TARGET)_top.v, $(SOURCES))
	@$(ICARUS) vvp $(TARGET).vvp | tools/showop.sh | tee test.tmp

modules:
	# $(ICARUS) iverilog -g2012 -o Skip.vvp Skip.vt Skip.v
	# $(ICARUS) vvp Skip.vvp 
	$(ICARUS) iverilog -g2012 -o UART.vvp UART.vt UART.v ClockGen.v
	$(ICARUS) vvp UART.vvp 



clean:
	@rm -f *.{tmp,blif,asc,bin,rpt,dot,png,json,vvp,vcd,svg,out,log}
	@rm -f .*_history
	@rm -f *~




#
# 	  -p 'synth_ice40 -top $(TARGET)_top -json $@; cd IRdecode; show -width -enum -stretch -prefix $(TARGET) -format dot'  \
#	@$(ICESTORM) dot -Tpng -O $(TARGET).dot
#
# TARGET=CLORIN
# image:
# 	@$(ICESTORM) yosys -p "prep; show -stretch -prefix $(TARGET) -format dot" $(TARGET).v > /dev/null
# 	@$(ICESTORM) dot -Tpng -O $(TARGET).dot > a.a
