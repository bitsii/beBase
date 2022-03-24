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

#rm -rf target5/Base/target/cc
export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy5 --buildPath target5 --emitFlag ccSgc
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#export CC=g++
#export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"

#singleCC false saveIds true
#g++ $CPFLAGS target5/Base/target/cc/be/BEH_4_Base.hpp
#time $MAKNAME -j 8 -f scripts/ext5cc.make
#time g++ $CPFLAGS -o target5/BEX_E_gn.exe target5/Base/target/cc/be/*.o

#-O1, O2, O3

#-pg for gprof perf, not needed for valgrind, which is better anyway
time g++ -DBEDCC_SGC=1 -o ./target5/BEX_E_gn.exe -Wfatal-errors -ggdb -std=c++11 ./target5/Base/target/cc/be/BEL_Base.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
