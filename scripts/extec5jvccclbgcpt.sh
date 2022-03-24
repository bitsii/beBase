#!/bin/bash

rm -rf targetEc/Base/target/cc
export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base --buildFile build/extendedEc.txt --emitLang cc --singleCC true --emitFlag ccBgc --emitFlag ccPt

#--emitFlag noSmap

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

#-DBED_GCSTATS=1

time clang++ -DBEDCC_PT=1 -DBEDCC_BGC=1 -pthread -o ./targetEc/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./targetEc/Base/target/cc/be/BEL_Base.cpp /usr/lib/x86_64-linux-gnu/libgc.a

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targetEc/BEX_E_cl.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)
