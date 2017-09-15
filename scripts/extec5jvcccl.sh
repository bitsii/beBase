#!/bin/bash

rm -rf targetEc/Base/target/cc
export CLASSPATH=target5/*
java be.BEX_E --buildFile build/extendedEc.txt --emitLang cc --singleCC true

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

clang++ -o ./targetEc/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./targetEc/Base/target/cc/be/BEX_E.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

