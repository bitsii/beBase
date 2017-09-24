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

java be.BEX_E --buildFile build/buildbuild.txt --emitLang cc --singleCC false --saveIds true --deployPath deploy5 --buildPath target5
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

export CC=g++
export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"

g++ $CPFLAGS target5/Base/target/cc/be/BEH_4_Base.hpp
time $MAKNAME -j 8 -f scripts/ext5cc.make
time g++ $CPFLAGS -o target5/BEX_E_gn.exe target5/Base/target/cc/be/*.o


