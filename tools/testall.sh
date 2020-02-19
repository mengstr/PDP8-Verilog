#!/bin/sh 

echo --------------------------------------------------------------------
echo InstTest1-D0AB
cp hex/InstTest1-D0AB.hex initialRAM.hex
make OSR=7777 CNT=100000 BP=7777 TRACE= test
exit

echo --------------------------------------------------------------------
echo InstTest2-D0BB
cp hex/InstTest2-D0BB.hex initialRAM.hex
make OSR=0000 CNT=100000 BP=3731 TRACE=NO test

echo --------------------------------------------------------------------
echo RandAND-D0DB
cp hex/RandAND-D0DB.hex initialRAM.hex
make OSR=0000 CNT=100000 BP=0322 TRACE=NO test

echo --------------------------------------------------------------------
echo focal-8
cp hex/focal-8.hex initialRAM.hex
make OSR=0000 CNT=1000000 BP=7777 TRACE=NO test

# echo AddTest-D0CC
# cp hex/AddTest-D0CC.hex initialRAM.hex
# make OSR=0000 CNT=100000 BP=3731 TRACE=NO test


# hex/CHEKMO.hex
# hex/JMPJMS-D0IB.hex
# hex/MemChecker-D1AA.hex
# hex/RIMLOADER.hex
# hex/RandDCA-D0GC.hex
# hex/RandJMPJMS-D0JB.hex
# hex/RandSZ-D0FC.hex
# hex/RandTAD-D0EB.hex
# hex/chkmoo.hex
# hex/file.hex
# hex/tty1.hex
# hex/tty2.hex
