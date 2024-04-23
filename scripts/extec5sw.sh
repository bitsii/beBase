#!/bin/bash

##rm -rf targetEc/Base/target/cc
mono --debug target5/BEX_E_mcs.exe --buildFile build/extendedEc.txt --emitLang sw

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

#time clang++ -pthread -o ./targetEc/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./targetEc/Base/target/cc/be/BEX_E.cpp

#rm targetEc/Base/target/sw/be/BEX_E.swift 

swiftc -suppress-warnings system/sw/*.swift targetEc/Base/target/sw/be/*.swift 2>&1 | more

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#time ./targetEc/BEX_E_cl.exe

#lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#CYC2=`date +%s`

#expr \( $CYC2 - $CYC1 \)

