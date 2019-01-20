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

rm -rf target4/Base/target/cc ./target4/BEX_E_cl.exe

#start with "perf record" to profile, see results with "perf report"
#to debug / get stack gdb --args 
#catch throw
#run

time ./target5/BEX_E_cl.exe --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy4 --buildPath target4

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#time clang++ -o ./target4/BEX_E_cl.exe -ferror-limit=1 -std=c++14 -pthread ./target4/Base/target/cc/be/BEX_E.cpp


