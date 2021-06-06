#!/bin/bash

rm -rf targetLibBasebrTest

time mono --debug target5/BEX_E_mcs.exe source/base/Uses.be --buildFile build/libBasebrTest.txt -loadSyns=lib/br/js/BEL_Base.syn -initLib=Base --emitLang js source/baseTest/TestHelloWorld.be

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

node targetLibBasebrTest/Test/target/js/be/BEL_Test.js $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
