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

time ./target5/BEX_E_cl.exe --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy4 --buildPath target4 --emitFlag ccSgc

#sudo apt-get install valgrind kcachegrind graphviz
#after just run kcachegrind
#time valgrind --tool=callgrind ./target5/BEX_E_cl.exe --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy4 --buildPath target4 --emitFlag ccSgc

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time clang++ -DBEDCC_SGC=1 -o ./target4/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./target4/Base/target/cc/be/BEL_Base.cpp


