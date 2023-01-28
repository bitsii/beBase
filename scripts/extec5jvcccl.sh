#!/bin/bash

una=`uname -a`
case "$una" in
  *Msys*)
    export MAKNAME="mingw32-make"
    ;;
  *)
    export MAKNAME="make"
    ;;
esac

#rm -rf targetEc/Base/target/cc

export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base --buildFile build/extendedEc.txt --emitLang cc --singleCC true --emitFlag ccSgc

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

#-DBED_GCSTATS=1

time clang++ -DBEDCC_SGC=1 -o ./targetEc/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./targetEc/Base/target/cc/be/BEL_Base.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targetEc/BEX_E_cl.exe

#sudo apt-get install valgrind kcachegrind graphviz
#valgrind --tool=callgrind ./targetEc/BEX_E_gn.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

