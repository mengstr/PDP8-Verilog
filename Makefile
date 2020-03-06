SHELL 		:= /bin/bash
PAL			:= tools/palbart
T2H			:= tools/tape2hexram.sh
ICEFLASH	:= ../verilog_old/upload/iceflash 

#
TARGET 		:= PDP8
SOURCES		:= $(wildcard *.v)

# If we run the makefile in CircleCI (or probably any other CI as well) we're runnig this from within a docker container
# already having all the required tools already installed, so we can just run the executables directly. Else just the 
# tools are run in a container with the work folder mapped to the real project folder at the host.
ifeq ($(CI), true)
	RUN		:= 
else
	DIR     := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
	RUN		:= docker run --rm --log-driver=none -a stdout -a stderr -w/work -v$(DIR)/:/work viacard/veritools
endif

# Building for the iCE40HX1K in a VQ100 package on the Olimex board
# having 100 MHz Crystal and target clock at 25 MHz
DEVICE 		:= hx1k
PACKAGE 	:= vq100
PCF    		:= olimex-pdp8.pcf
PNRCLKGOAL  := 25
PORT		:= /dev/cu.usbmodem48065801

# Default values for running the tests, can be overridden on the commandline like
#	make test CNT=100 TRACE=NO
OSR		?=	0000
BP		?=	7777
CNT		?=	100
TRACE	?=
DELAY	?=	0

# Defines currently needed for yosys
DEFS		:= -DOSR=$(OSR) 

# Colored text excape strings
rev			:= $$(tput -Txterm-256color bold)
norm		:= $$(tput -Txterm-256color sgr0)
red			:= $$(tput -Txterm-256color setab 1)
green		:= $$(tput -Txterm-256color setab 2)
yellow		:= $$(tput -Txterm-256color setab 3)

# List of all test/demo sources/binaries to be converted into hex files for loading
HEXSOURCES 	:= $(addsuffix .hex,$(basename $(wildcard sw/src/*.pal sw/src/*.pt sw/src/*.bin sw/src/*.bn)))
HEXTARGETS 	:= $(subst sw/src/,sw/hex/,$(HEXSOURCES))

.PHONY: all report upload lint clean test

#
# makefile default operations:
# 	1) Create all the hexfiles
#	2) Create the bitstream from verilog sources
#	3) Report utilization and speed
#
all:  $(HEXTARGETS) $(TARGET).bin report


#
# Process the verilog files
#
$(TARGET).json: $(SOURCES) initialRAM.hex Makefile $(PCF)
	@echo "${rev}###  yosys $(DEFS) ###${norm}"
	@$(RUN) yosys \
	  $(DEFS) \
	  -q \
	  -p 'synth_ice40 -top $(TARGET)_top -json $@'  \
	  $(SOURCES) > yosys.tmp


#
# Place and route
#
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


#
# Use ICEPACK to convert the ASCII bitstream into the BINARY that can be uploaded
#
$(TARGET).bin: $(TARGET).asc
	@echo "${rev}###  icepack ###${norm}"
	@$(RUN) icepack \
	$< \
	$@ 2>&1 | tee icepack.tmp


#
# Analyze the speed of the design and see if it meets the goal speed
#
icetime0.tmp: $(TARGET).asc
	@echo "${rev}###  icetime -c $(PNRCLKGOAL) ###${norm}"
	@$(RUN) icetime \
	-d $(DEVICE) \
	-c $(PNRCLKGOAL) \
	-m \
	-t \
	-r icetime0.tmp \
	$(TARGET).asc 2>icetime2.tmp 1>icetime1.tmp


#
# Show FPGA utilization and max speed
#
report: icetime0.tmp
	@echo ""
	@grep "Device utilisation:" -A6 nextpnr2.tmp | tail -6 | sed "s/Info://g" | cut -c 9-
	@cat icetime1.tmp | grep -A1 'Timing' | sed 's/\/\/ /  /g'
	@echo ""


#
# Upload the bitstream to FPGA
#
upload:$(TARGET).bin
	@echo "${rev}###  iceflash $(PORT) -h -e -w $(TARGET).bin -t -G ###${norm}"
	@$(ICEFLASH) $(PORT) -h -e -w $(TARGET).bin -t -G
	tio $(PORT) 


#
# Let verilator hava a go at linting the system
#
lint: $(SOURCES)
	@echo "${rev}###  verilator --lint-only $(DEFS) ###${norm}"
	@$(RUN) verilator \
		-Wall \
		$(DEFS) \
		--top-module $(TARGET)_top \
		--lint-only \
		$^ 2>&1 | tee lint.tmp

#
# Runs the current initialRAM.hex in the testbench
#
test: initialRAM.hex
	@$(call runtest,../../initalRAM.hex,$(OSR),$(CNT),$(BP),$(DELAY),$(TRACE)); \


#
# Runs all tests/MAINDECS and verifies that the execution was correct
#
testall: $(HEXTARGETS) patch.tmp
	@$(call runtest,InstTest1-D0AB,1234,100000,5276,0,NO); \
	if [ $$(grep -c 'HLT at 0500' test.tmp) -eq 1 ]; then echo "${green}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; fi

	@$(call runtest,InstTest1-D0AB,7777,200000,XXXX,0,NO); \
	if [ $$(grep -c 'TX 135' test.tmp) -eq 5 ]; then echo "${green}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; false; fi 
	
	@$(call runtest,InstTest2-D0BB,0000,200000,XXXX,0,NO); \
	if [ $$(grep -c 'TX 135' test.tmp) -eq 7 ]; then echo "${green}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; false; fi 

	@$(call runtest,JMPJMS-D0IB,0000,400000,XXXX,0,NO); \
	if [ $$(grep -c 'TX 135' test.tmp) -eq 5 ]; then echo "${green}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; false; fi 

	@$(call runtest,RandAND-D0DB,0000,400000,0324,0,NO); \
	if [ $$(grep -c 'DONE' test.tmp) -eq 1 ]; then echo "${yellow}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; false; fi

	@$(call runtest,RandTAD-D0EB,0000,400000,7443,0,NO); \
	if [ $$(grep -c 'DONE' test.tmp) -eq 1 ]; then echo "${yellow}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; false; fi

	@$(call runtest,RandDCA-D0GC,0000,10000000,0150,0,NO); \
	if [ $$(grep -c 'DONE' test.tmp) -eq 1 ]; then echo "${yellow}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; false; fi

	@$(call runtest,RandISZ-D0FC,0000,10000,7777,0,NO); \
	if [ $$(grep -c 'DONE' test.tmp) -eq 1 ]; then echo "${yellow}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; false; fi

	@$(call runtest,RandJMPJMS-D0JB,0000,10000,7777,0,NO); \
	if [ $$(grep -c 'DONE' test.tmp) -eq 1 ]; then echo "${yellow}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; false; fi

	@$(call runtest,MemChecker-D1AA,0000,10000,7777,0,NO); \
	if [ $$(grep -c 'DONE' test.tmp) -eq 1 ]; then echo "${yellow}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; false; fi

	@$(call runtest,focal-8,0000,200000,7777,0,NO); \
	if [ $$(grep -c 'TX 33' test.tmp) -gt 0 ]; then echo "${green}    SUCCESS    ${norm}"; else echo "${red}      FAIL     ${norm}"; false; fi

# echo --------------------------------------------------------------------
# echo focal-8 multitests
# focal-8.hex initialRAM.hex
# for dly in {19..20}; do
#     make OSR=0000 CNT=200000 BP=7777 DELAY=$dly TRACE=NO test
#     grep -q -s 'TX 33 (!)' test.tmp
#     if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi
# done
#AddTest-D0CC OSR=0000 CNT=100000 BP=3731 TRACE=NO test


#
# Function that runs the specified hexfile in the testbench - called by 'test' and 'testall'
#
define runtest
	echo 
	echo ${rev} ---  iverilog -DOSR=$(2) -DCNT=$(3) -DBP=$(4) -DDELAY=$(5) -D$(6)TRACE $(1) --- ${norm}
	cp sw/hex/$(1).hex initialRAM.hex 2> /dev/null || true
	$(RUN) iverilog -g2012 -DIVERILOG -DOSR=$(2) -DBP=$(4) -D$(6)TRACE -DCNT=$(3) -DDELAY=$(5) -o $(TARGET).vvp $(TARGET).vt $(filter-out $(TARGET)_top.v, $(SOURCES))
	$(RUN) vvp $(TARGET).vvp | sed '/dumpfile/d' | tools/showop.sh | tee test.tmp
endef


#
# Run all module testbenches
#
modules:
	#$(RUN) iverilog -g2012 -o Skip.vvp Skip.vt Skip.v
	#$(RUN) vvp Skip.vvp 
	#$(RUN) iverilog -g2012 -o UART.vvp UART.vt UART.v ClockGen.v
	#$(RUN) vvp UART.vvp 


#
# Create the palbart assembler from source
#
tools/palbart: tools/src/palbart.c 
	$(CC) -Os -o $@ $<


#
# Set the initialRAM to the NOP-software
#
initialRAM.hex : sw/hex/NOP.hex
	@cp $< $@


#
# Run the .pal assembly sources thru palbart and convert the binary into hexes
#
sw/hex/%.hex: sw/src/%.pal tools/palbart
	@mkdir -p sw/tmp sw/hex
	@cp -f $< $(dir $<)../tmp/
	$(PAL) -t 8 -a -r sw/tmp/$(basename $(notdir $<)).pal
	$(T2H) < sw/tmp/$(basename $(notdir $<)).rim > sw/hex/$(basename $(notdir $<)).hex


#
# Convert all pre-made vareities of binary files into hexes
#
sw/hex/%.hex: sw/src/%.pt
	@mkdir -p sw/tmp sw/hex
	$(T2H) < $< > sw/hex/$(basename $(notdir $<)).hex

sw/hex/%.hex: sw/src/%.bn
	@mkdir -p sw/tmp sw/hex
	$(T2H) < $< > sw/hex/$(basename $(notdir $<)).hex

sw/hex/%.hex: sw/src/%.bin
	@mkdir -p sw/tmp sw/hex
	$(T2H) < $< > sw/hex/$(basename $(notdir $<)).hex


#
# Patch hexes to run better/faster in the testbench
#
patch.tmp: $(HEXTARGETS)
	@touch patch.tmp
	# Patch initial HLT to be a NOP
	# Patch loop counter initial and reload values to -1
	sed -i $$(printf "%d" $$((0146+1)))s/$$(printf "%03x" 07402)/$$(printf "%03x" 07000)/ sw/hex/InstTest1-D0AB.hex
	sed -i $$(printf "%d" $$((0121+1)))s/$$(printf "%03x" 05140)/$$(printf "%03x" 07777)/ sw/hex/InstTest1-D0AB.hex
	sed -i $$(printf "%d" $$((0122+1)))s/$$(printf "%03x" 05140)/$$(printf "%03x" 07777)/ sw/hex/InstTest1-D0AB.hex
	#
	# Patch loop counter stop value to -1
	sed -i $$(printf "%d" $$((03750+1)))s/$$(printf "%03x" 04762)/$$(printf "%03x" 07777)/ sw/hex/InstTest2-D0BB.hex
	# Patch loop counter stop value to -1
	sed -i $$(printf "%d" $$((03572+1)))s/$$(printf "%03x" 01200)/$$(printf "%03x" 07777)/ sw/hex/JMPJMS-D0IB.hex



#
# Delete all created artifacts
#
clean:
	@rm -f *.{tmp,blif,asc,bin,rpt,dot,png,json,vvp,vcd,svg,out,log,hex,gtkw}
	@rm -f sw/{hex,tmp}/*
	@rm -f tools/palbart
	@rm -f .*_history *~
