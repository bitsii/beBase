#!/bin/bash

rm -rf targetEc/Base/target/cc
mono --debug target5/BEX_E_mcs.exe --buildFile build/extendedEc.txt --emitLang cc

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

clang++ -o ./targetEc/BEX_E_clang.exe -ferror-limit=1 -std=c++11 ./targetEc/Base/target/cc/be/BEX_E.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

#g++ -o ./targetEc/BEX_E_gcc.exe -Wfatal-errors -std=c++11 ./targetEc/Base/target/cc/be/BEX_E.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC3=`date +%s`

expr \( $CYC3 - $CYC2 \)
