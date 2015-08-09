#!/bin/sh

rm -rf targetEc/Base/target/cs
rm -f targetEc/BEL_4_Base_mcs.exe
mono --debug target5/BEL_4_Base_mcs.exe --buildFile build/extendedEc.txt --emitLang cs
# --printAstElement Container:Map.addValue.178 --printAllAst true
mcs -debug:pdbonly -warn:0 -out:targetEc/BEL_4_Base_mcs.exe -warn:0 system/cs/be/BELS_Base/*.cs targetEc/Base/target/cs/be/BEL_4_Base/*.cs
mono --debug targetEc/BEL_4_Base_mcs.exe $*
