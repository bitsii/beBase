#!/bin/bash

rm -rf targetEc/Base/target/cc
mono --debug target5/BEX_E_mcs.exe --buildFile build/extendedEc.txt --emitLang cc --singleCC true --emitFlag ccBgc --emitFlag ccPt

#--emitFlag noSmap

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

time clang++ -DBEDCC_PT=1 -DBEDCC_BGC=1 -pthread -o ./targetEc/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./targetEc/Base/target/cc/be/BEL_Base.cpp /usr/lib/x86_64-linux-gnu/libgc.a

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targetEc/BEX_E_cl.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

