#!/bin/sh 

echo --------------------------------------------------------------------
echo InstTest1-D0AB
cp hex/InstTest1-D0AB.hex initialRAM.hex
time make OSR=7777 CNT=100000 BP=5276 TRACE=NO test


echo --------------------------------------------------------------------
echo InstTest2-D0BB
cp hex/InstTest2-D0BB.hex initialRAM.hex
time make OSR=0000 CNT=100000 BP=3731 TRACE=NO test


echo --------------------------------------------------------------------
echo JMPJMS-D0IB
cp hex/JMPJMS-D0IB.hex initialRAM.hex
time make OSR=0000 CNT=1000000 BP=3551 TRACE=no test


echo --------------------------------------------------------------------
echo RandJMPJMS-D0JB
cp hex/RandJMPJMS-D0JB.hex initialRAM.hex
time make OSR=0000 CNT=1000000 BP=0346 TRACE=no test


echo --------------------------------------------------------------------
echo RandAND-D0DB
cp hex/RandAND-D0DB.hex initialRAM.hex
time make OSR=0000 CNT=100000 BP=0322 TRACE=NO test


echo --------------------------------------------------------------------
echo RandTAD-D0EB
cp hex/RandTAD-D0EB.hex initialRAM.hex
time make OSR=0000 CNT=100000 BP=6743 TRACE=NO test
#time make OSR=0000 CNT=1000000 BP=7443 TRACE=NO test


echo --------------------------------------------------------------------
echo RandDCA-D0GC
cp hex/RandDCA-D0GC.hex initialRAM.hex
time make OSR=0000 CNT=500000 BP=7777 TRACE=NO test


echo --------------------------------------------------------------------
echo RandISZ-D0FC
cp hex/RandISZ-D0FC.hex initialRAM.hex
time make OSR=0000 CNT=1000000 BP=7777 TRACE=no test


echo --------------------------------------------------------------------
echo MemChecker-D1AA
cp hex/MemChecker-D1AA.hex initialRAM.hex
time make OSR=0000 CNT=500000 BP=7777 TRACE=NO test


echo --------------------------------------------------------------------
echo focal-8
cp hex/focal-8.hex initialRAM.hex
time make OSR=0000 CNT=1000000 BP=7777 TRACE=NO test




# echo AddTest-D0CC
# cp hex/AddTest-D0CC.hex initialRAM.hex
# make OSR=0000 CNT=100000 BP=3731 TRACE=NO test


# hex/CHEKMO.hex
# hex/RIMLOADER.hex
# hex/chkmoo.hex
# hex/file.hex
# hex/tty1.hex
# hex/tty2.hex
