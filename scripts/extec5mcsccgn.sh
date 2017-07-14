#!/bin/bash

#rm -rf targetEc/Base/target/cc
mono --debug target5/BEX_E_mcs.exe --buildFile build/extendedEc.txt --emitLang cc --singleCC false --saveIds true
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

export CC=g++

#-DDEBUG

export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"

g++ $CPFLAGS targetEc/Base/target/cc/be/BEH_4_Base.hpp

time mingw32-make -j 8 -f scripts/extecc.make

time g++ $CPFLAGS -o targetEc/BEX_E_gn.exe targetEc/Base/target/cc/be/*.o

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

