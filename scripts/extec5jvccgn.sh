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
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base -cchImport=system/cc/be/BEH_SGCBEQ.hpp --buildFile build/extendedEc.txt --emitLang cc --singleCC true --emitFlag ccSgc --emitFlag bemdSmall

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

export CC=g++
export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"

time g++ $CPFLAGS -o targetEc/BEX_E_gn.exe ./targetEc/Base/target/cc/be/BEL_Base.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targetEc/BEX_E_gn.exe

#sudo apt-get install valgrind kcachegrind graphviz
#valgrind --tool=callgrind ./targetEc/BEX_E_gn.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

