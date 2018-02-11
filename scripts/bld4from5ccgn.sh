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

#start with "perf record" to profile, see results with "perf report"
#to debug / get stack gdb --args 
#catch throw
#run

time ./target5/BEX_E_gn.exe --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy4 --buildPath target4

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#export CC=g++
#export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"

#g++ $CPFLAGS target4/Base/target/cc/be/BEH_4_Base.hpp
#time $MAKNAME -j 8 -f scripts/ext4cc.make
#time g++ $CPFLAGS -o target4/BEX_E_gn.exe target4/Base/target/cc/be/*.o

#time g++ -o ./target4/BEX_E_gn.exe -Wfatal-errors -ggdb -std=c++11 ./target4/Base/target/cc/be/BEX_E.cpp


