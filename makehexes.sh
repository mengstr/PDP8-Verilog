#!/bin/bash

echo "Converting tty1.pal"
../tools/palbart ../asm/tty1.pal
mv -f ../asm/tty1.bin ../bin/
./tape2hexram.sh < ../bin/tty1.bin              > RAM.tty1.hex

echo "Converting D0AB-InstTest-1.pt"
./tape2hexram.sh < ../bin/D0AB-InstTest-1.pt    > RAM.Inst1.hex
# Patch initial HLT to be a NOP inestead
sed -i '' '103s/f02/e00/' RAM.Inst1.hex

echo -e "\nConverting D0BB-InstTest-2.pt"
./tape2hexram.sh < ../bin/D0BB-InstTest-2.pt    > RAM.Inst2.hex

echo -e "\nConverting D0CC-AddTest.pt"
./tape2hexram.sh < ../bin/D0CC-AddTest.pt       > RAM.AddTest.hex

echo -e "\nConverting D0DB-RandomAND.pt"
./tape2hexram.sh < ../bin/D0DB-RandomAND.pt     > RAM.RandomAND.hex

echo -e "\nConverting D0EB-Random-TAD.pt"
./tape2hexram.sh < ../bin/D0EB-Random-TAD.pt    > RAM.RandomTAD.hex

echo -e "\nConverting D0FC-Random-ISZ.pt"
./tape2hexram.sh < ../bin/D0FC-Random-ISZ.pt    > RAM.RandomISZ.hex

echo -e "\nConverting D0GC-Random-DCA.pt"
./tape2hexram.sh < ../bin/D0GC-Random-DCA.pt    > RAM.RandomDCA.hex

echo -e "\nConverting D0IB-JMPJMS.pt"
./tape2hexram.sh < ../bin/D0IB-JMPJMS.pt        > RAM.JMPJMS.hex

echo -e "\nConverting D0JB-JMPJMS-RANDOM"
./tape2hexram.sh < ../bin/D0JB-JMPJMS-RANDOM.pt > RAM.RandomJMPJMP.hex

echo -e "\nConverting focal-8"
./tape2hexram.sh < ../bin/focal-8.bin           > RAM.Focal-8.hex

