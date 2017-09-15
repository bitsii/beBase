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
java be.BEX_E --buildFile build/extendedEc.txt --emitLang cc --singleCC false --saveIds true
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

export CC=g++

#-DDEBUG

export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"

g++ $CPFLAGS targetEc/Base/target/cc/be/BEH_4_Base.hpp

time $MAKNAME -j 8 -f scripts/extecc.make

time g++ $CPFLAGS -o targetEc/BEX_E_gn.exe targetEc/Base/target/cc/be/*.o

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

