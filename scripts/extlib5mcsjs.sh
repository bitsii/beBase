#!/bin/bash

rm -rf targetExtLib

time mono --debug target5/BEX_E_mcs.exe --buildFile build/extLib.txt --emitLang js

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#mono --debug target5\BEX_E_mcs.exe source/Base/Uses.be --buildFile build\extExe.txt -loadSyns=targetExtLib/Base/target/cs/be/BEX_E.syn --emitLang cs

# --printAstElement Container:Map.addValue.178 --printAllAst true
#mcs -debug:pdbonly -warn:0 -t:library -out:targetExtLib/BEX_E_mcs.dll -warn:0 system/cs/be/*.cs targetExtLib/Base/target/cs/be/*.cs

#lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time mono --debug target5/BEX_E_mcs.exe source/base/Uses.be --buildFile build/extExe.txt -loadSyns=targetExtLib/Base/target/js/be/BEX_E.syn -jsInclude=targetExtLib/Base/target/js/be/BEX_E.js --emitLang js

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#mcs -debug:pdbonly /warn:0 -r:targetExtLib/BEX_E_mcs.dll -out:targetExtLib/BEX_E_mcs.exe /warn:0 targetExtLib/Test/target/cs/be/*.cs

#lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

node targetExtLib/Test/target/js/be/BEX_E.js $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
