#!/bin/sh

rm -rf targetEc/Base/target/cs
rm -f targetEc/BEL_4_Base_mcs.exe
mono --debug target5/BEL_4_Base_mcs.exe --buildFile build/extendedEc.txt --emitLang cs
mcs -debug:pdbonly -warn:0 -out:targetEc/BEL_4_Base_mcs.exe -warn:0 system/cs/abe/BELS_Base/*.cs targetEc/Base/target/cs/abe/BEL_4_Base/*.cs
mono --debug targetEc/BEL_4_Base_mcs.exe $*
