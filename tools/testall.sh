#!/bin/sh 
green=$(tput setab 2)
red=$(tput setab 1)
norm=$(tput sgr0)

DELAY=0

echo --------------------------------------------------------------------
echo InstTest1-D0AB should halt
cp hex/InstTest1-D0AB.hex initialRAM.hex
make OSR=1234 CNT=100000 BP=5276 DELAY=$DELAY TRACE=NO test
grep -q -s 'HLT at' test.tmp
if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi


echo --------------------------------------------------------------------
echo InstTest1-D0AB
cp hex/InstTest1-D0AB.hex initialRAM.hex
make OSR=7777 CNT=100000 BP=5276 DELAY=$DELAY TRACE=NO test
grep -q -s 'BP at' test.tmp
if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi


echo --------------------------------------------------------------------
echo InstTest2-D0BB
cp hex/InstTest2-D0BB.hex initialRAM.hex
make OSR=0000 CNT=100000 BP=3731 DELAY=$DELAY TRACE=NO test
grep -q -s 'BP at' test.tmp
if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi


echo --------------------------------------------------------------------
echo JMPJMS-D0IB
cp hex/JMPJMS-D0IB.hex initialRAM.hex
make OSR=0000 CNT=1000000 BP=3551 DELAY=$DELAY TRACE=no test
grep -q -s 'BP at' test.tmp
if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi


echo --------------------------------------------------------------------
echo RandJMPJMS-D0JB
cp hex/RandJMPJMS-D0JB.hex initialRAM.hex
make OSR=0000 CNT=1000000 BP=0346 DELAY=$DELAY TRACE=no test
# if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi


echo --------------------------------------------------------------------
echo RandAND-D0DB
cp hex/RandAND-D0DB.hex initialRAM.hex
make OSR=0000 CNT=100000 BP=0322 DELAY=$DELAY TRACE=NO test
grep -q -s 'BP at' test.tmp
if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi


echo --------------------------------------------------------------------
echo RandTAD-D0EB
cp hex/RandTAD-D0EB.hex initialRAM.hex
make OSR=0000 CNT=100000 BP=6743 DELAY=$DELAY TRACE=NO test
# if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi


echo --------------------------------------------------------------------
echo RandDCA-D0GC
cp hex/RandDCA-D0GC.hex initialRAM.hex
make OSR=0000 CNT=500000 BP=7777 DELAY=$DELAY TRACE=NO test
# if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi


echo --------------------------------------------------------------------
echo RandISZ-D0FC
cp hex/RandISZ-D0FC.hex initialRAM.hex
make OSR=0000 CNT=1000000 BP=7777 DELAY=$DELAY TRACE=no test
# if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi


echo --------------------------------------------------------------------
echo MemChecker-D1AA
cp hex/MemChecker-D1AA.hex initialRAM.hex
make OSR=0000 CNT=500000 BP=7777 DELAY=$DELAY TRACE=NO test
# if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi


echo --------------------------------------------------------------------
echo focal-8
cp hex/focal-8.hex initialRAM.hex
make OSR=0000 CNT=200000 BP=7777 DELAY=$DELAY TRACE=NO test
grep -q -s 'TX 33 (!)' test.tmp
if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi

exit

echo --------------------------------------------------------------------
echo focal-8 multitests
cp hex/focal-8.hex initialRAM.hex
for dly in {19..20}; do
    make OSR=0000 CNT=200000 BP=7777 DELAY=$dly TRACE=NO test
    grep -q -s 'TX 33 (!)' test.tmp
    if [ "$?" == "0" ]; then echo "$green    SUCCESS    $norm"; else echo "$red      FAIL     $norm"; fi
done



# echo AddTest-D0CC
# cp hex/AddTest-D0CC.hex initialRAM.hex
# make OSR=0000 CNT=100000 BP=3731 TRACE=NO test


# hex/CHEKMO.hex
# hex/RIMLOADER.hex
# hex/chkmoo.hex
# hex/file.hex
# hex/tty1.hex
# hex/tty2.hex
