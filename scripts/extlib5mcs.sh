#!/bin/bash

rm -rf targetExtLib

time mono --debug target5/BEX_E_mcs.exe --buildFile build/extLib.txt --emitLang cs --doMain false

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#mono --debug target5\BEX_E_mcs.exe source/Base/Uses.be --buildFile build\extExe.txt -loadSyns=targetExtLib/Base/target/cs/be/BEX_E.syn --emitLang cs

# --printAstElement Container:Map.addValue.178 --printAllAst true
mcs -debug:pdbonly -warn:0 -t:library -out:targetExtLib/BEL_Base.dll -warn:0 system/cs/be/*.cs targetExtLib/Base/target/cs/be/*.cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time mono --debug target5/BEX_E_mcs.exe source/base/Uses.be --buildFile build/extExe.txt -loadSyns=targetExtLib/Base/target/cs/be/BEL_Base.syn -loadIds=targetExtLib/Base/target/cs/be/BEL_Base -initLib=Base --emitLang cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#mcs -debug:pdbonly /warn:0 -main:be.BEX_E -r:targetExtLib/BEX_E_mcs.dll -out:targetExtLib/BEX_E_mcs.exe /warn:0 targetExtLib/Test/target/cs/be/*.cs

mcs -debug:pdbonly /warn:0 -out:targetExtLib/BEL_Test.exe -reference:targetExtLib/BEL_Base.dll /warn:0 targetExtLib/Test/target/cs/be/*.cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

mono --debug targetExtLib/BEL_Test.exe $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
