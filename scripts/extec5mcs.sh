#!/bin/bash

rm -rf targetEc/Base/target/cs
rm -f targetEc/BEL_4_Base_mcs.exe
mono --debug target5/BEL_4_Base_mcs.exe --buildFile build/extendedEc.txt --emitLang cs
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
# --printAstElement Container:Map.addValue.178 --printAllAst true
mcs -debug:pdbonly -warn:0 -out:targetEc/BEL_4_Base_mcs.exe -warn:0 system/cs/be/*.cs targetEc/Base/target/cs/be/*.cs
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
mono --debug targetEc/BEL_4_Base_mcs.exe $*
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
