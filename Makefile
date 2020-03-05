PORT:=/dev/cu.usbmodem48065801

# Building for the iCE40HX1K in a VQ100 package on the Olimex board
# having 100 MHz Crystal and target clock at 12.5 MHz
DEVICE 		:= hx1k
PACKAGE 	:= vq100
PCF    		:= olimex-pdp8.pcf
PNRCLKGOAL  := 25

OSR			:= 0000
DEFS		:= -DOSR=$(OSR) 
DELAY		:= 0

TARGET 		:= PDP8
SOURCES		:= $(wildcard *.v)
DIR         := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

ifeq ($(CI),"true")
	RUN		:= ""
else
	RUN		:= docker run --rm --log-driver=none -a stdout -a stderr -w/work -v$(DIR)/:/work viacard/veritools
endif

ICEFLASH	:= ../verilog_old/upload/iceflash 
PAL			:= tools/palbart
T2H			:= tools/tape2hexram.sh

rev			:= $$(tput bold)
norm		:= $$(tput sgr0)

HEXSOURCES 	:= $(addsuffix .hex,$(basename $(wildcard sw/src/*.pal sw/src/*.pt sw/src/*.bin sw/src/*.bn)))
HEXTARGETS 	:= $(subst sw/src/,sw/hex/,$(HEXSOURCES))

.PHONY: all report upload lint clean test

all:  $(HEXTARGETS) $(TARGET).bin report

$(TARGET).json: $(SOURCES) initialRAM.hex Makefile $(PCF)
	@echo "${rev}###  yosys $(DEFS) ###${norm}"
	@$(RUN) yosys \
	  $(DEFS) \
	  -q \
	  -p 'synth_ice40 -top $(TARGET)_top -json $@'  \
	  $(SOURCES) > yosys.tmp


$(TARGET).asc: $(TARGET).json
	@echo "${rev}###  nextpnr --freq $(PNRCLKGOAL) ###${norm}"
	@$(RUN) nextpnr-ice40 \
	--$(DEVICE) \
	--package $(PACKAGE) \
	--pcf $(PCF) \
	--freq $(PNRCLKGOAL) \
	--pcf-allow-unconstrained \
	--json $< \
	--asc $@  2>nextpnr2.tmp 1>nextpnr1.tmp


$(TARGET).bin: $(TARGET).asc
	@echo "${rev}###  icepack ###${norm}"
	@$(RUN) icepack \
	$< \
	$@ 2>&1 | tee icepack.tmp


icetime0.tmp: $(TARGET).asc
	@echo "${rev}###  icetime -c $(PNRCLKGOAL) ###${norm}"
	@$(RUN) icetime \
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
	@$(RUN) verilator \
		-Wall \
		$(DEFS) \
		--top-module $(TARGET)_top \
		--lint-only \
		$^ 2>&1 | tee lint.tmp

CNT:=100000
OSR:=0000
BP:=7777
TRACE:=

test:
	@echo "${rev}###  iverilog -DOSR=$(OSR) -DCNT=$(CNT) -DBP=$(BP) -DDELAY=$(DELAY) -D$(TRACE)TRACE  ###${norm}"
	@$(RUN) iverilog -g2012 \
		-DIVERILOG \
		-DOSR=$(OSR) \
		-DBP=$(BP) \
		-D$(TRACE)TRACE \
		-DCNT=$(CNT) \
		-DDELAY=$(DELAY) \
		-o $(TARGET).vvp \
		$(TARGET).vt $(filter-out $(TARGET)_top.v, $(SOURCES))
	@$(RUN) vvp $(TARGET).vvp | tools/showop.sh | tee test.tmp

modules:
	# $(ICARUS) iverilog -g2012 -o Skip.vvp Skip.vt Skip.v
	# $(ICARUS) vvp Skip.vvp 
	@$(RUN) iverilog -g2012 -o UART.vvp UART.vt UART.v ClockGen.v
	@$(RUN) vvp UART.vvp 

sw/hex/%.hex: sw/src/%.pal
	@mkdir -p sw/tmp sw/hex
	@cp -f $< $(dir $<)../tmp/
	$(PAL) -a -r sw/tmp/$(basename $(notdir $<)).pal
	$(T2H) < sw/tmp/$(basename $(notdir $<)).rim > sw/hex/$(basename $(notdir $<)).hex

sw/hex/%.hex: sw/src/%.pt
	@mkdir -p sw/tmp sw/hex
	$(T2H) < $< > sw/hex/$(basename $(notdir $<)).hex

sw/hex/%.hex: sw/src/%.bn
	@mkdir -p sw/tmp sw/hex
	$(T2H) < $< > sw/hex/$(basename $(notdir $<)).hex

sw/hex/%.hex: sw/src/%.bin
	@mkdir -p sw/tmp sw/hex
	$(T2H) < $< > sw/hex/$(basename $(notdir $<)).hex

initialRAM.hex : sw/hex/NOP.hex
	@cp $< $@
	
clean:
	@rm -f *.{tmp,blif,asc,bin,rpt,dot,png,json,vvp,vcd,svg,out,log,hex}
	@rm -f sw/{hex,tmp}/*
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
