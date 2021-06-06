#!/bin/bash

rm -rf targetLibBaseexTest

time mono --debug target5/BEX_E_mcs.exe source/base/Uses.be --buildFile build/libBaseexTest.txt -loadSyns=lib/ex/jv/BEL_Base.syn -loadIds=lib/ex/jv/BEL_Base -initLib=Base --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

javac -classpath lib/ex/jv/BES_System.jar:lib/ex/jv/BEL_Base.jar targetLibBaseexTest/Test/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

java -classpath lib/ex/jv/BES_System.jar:lib/ex/jv/BEL_Base.jar:targetLibBaseexTest/Test/target/jv be.BEL_Test $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
