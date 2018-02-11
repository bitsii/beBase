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
#start with "perf record" to profile, see results with "perf report"
#gdb --args ...

time target5/BEX_E_gn.exe --buildFile build/extendedEc.txt --emitLang cc --singleCC true --saveIds false

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

#exit 0

#export CC=g++
#export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"

#g++ $CPFLAGS targetEc/Base/target/cc/be/BEH_4_Base.hpp
#time $MAKNAME -j 8 -f scripts/extecc.make
#time g++ $CPFLAGS -o targetEc/BEX_E_gn.exe targetEc/Base/target/cc/be/*.o

g++ -o ./targetEc/BEX_E_gn.exe -Wfatal-errors -ggdb -std=c++11 ./targetEc/Base/target/cc/be/BEX_E.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targetEc/BEX_E_gn.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

