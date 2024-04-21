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

rm -rf targets/min/Base/target/cc/be
rm -f targets/min/BEX_E_cl.exe

export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base -deployPath=targets/tiny -buildPath=targets/tiny -cchImport=system/cc/be/BEH_SGCBEQ.hpp --buildFile build/tinyBase.txt --emitLang cc --singleCC true --emitFlag ccSgc --emitFlag ccNoRtti --emitFlag noSmap --emitFlag noRfl --emitFlag noBet --emitFlag bemdSmall --mainClass Test:TestHelloWorld ../beBase/source/baseTest/TestHelloWorld.be

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

export CC=g++
export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"

time g++ $CPFLAGS -DBEDCC_SGC=1 -o targets/tiny/BEX_E_gn.exe ./targets/tiny/Base/target/cc/be/BEL_Base.cpp


lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targets/tiny/BEX_E_gn.exe

#sudo apt-get install valgrind kcachegrind graphviz
#valgrind --tool=callgrind ./targetEc/BEX_E_gn.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

