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

rm -rf targetEc/Base/target/cc ./targetEc/BEX_E_cl.exe

time target5/BEX_E_cl.exe --buildFile build/extendedEc.txt --emitLang cc --singleCC true --emitFlag ccSgc

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

#exit 0

clang++ -DBEDCC_SGC=1 -o ./targetEc/BEX_E_cl.exe -ferror-limit=1 -std=c++14 ./targetEc/Base/target/cc/be/BEX_E.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time clang++ -o ./target5/BEX_E_cl.exe -ferror-limit=1 -std=c++14 ./target5/Base/target/cc/be/BEX_E.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targetEc/BEX_E_cl.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

