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

time target5/BEX_E_gn.exe --buildFile build/extendedEc.txt --emitLang cc --singleCC false --saveIds true

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

#exit 0

export CC=g++
export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"

g++ $CPFLAGS targetEc/Base/target/cc/be/BEH_4_Base.hpp
time $MAKNAME -j 8 -f scripts/extecc.make
time g++ $CPFLAGS -o targetEc/BEX_E_gn.exe targetEc/Base/target/cc/be/*.o

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

