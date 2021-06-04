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

mono --debug target5/BEX_E_mcs.exe --buildFile build/extendedEc.txt --emitLang cc --singleCC true --emitFlag ccSgc

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

export CC=g++
export CPFLAGS="-std=c++14 -Wfatal-errors -ggdb"

time g++ $CPFLAGS -DBEDCC_SGC=1 -pthread -o targetEc/BEX_E_gn.exe ./targetEc/Base/target/cc/be/BEL_Base.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targetEc/BEX_E_gn.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

