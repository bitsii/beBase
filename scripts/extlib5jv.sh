#!/bin/bash

rm -rf targetExtLib

time mono --debug target5/BEX_E_mcs.exe --buildFile build/extLib.txt --emitLang jv --doMain false

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

javac system/jv/be/*.java targetExtLib/Base/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time mono --debug target5/BEX_E_mcs.exe source/base/Uses.be --buildFile build/extExe.txt -loadSyns=targetExtLib/Base/target/jv/be/BEL_Base.syn -loadIds=targetExtLib/Base/target/jv/be/BEL_Base -initLib=Base --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

javac -classpath system/jv:targetExtLib/Base/target/jv targetExtLib/Test/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

java -classpath system/jv:targetExtLib/Base/target/jv:targetExtLib/Test/target/jv be.BEL_Test $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
