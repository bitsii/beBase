#!/bin/bash

rm -rf targetLibBaseTest

time mono --debug target5/BEX_E_mcs.exe source/base/Uses.be --buildFile build/libBaseTest.txt -loadSyns=lib/jv/BEL_Base.syn -loadIds=lib/jv/BEL_Base -initLib=Base --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

javac -classpath lib/jv/BES_System.jar:lib/jv/BEL_Base.jar targetLibBaseTest/Test/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

java -classpath lib/jv/BES_System.jar:lib/jv/BEL_Base.jar:targetLibBaseTest/Test/target/jv be.BEL_Test $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
