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

#debug "run" to get going, "backtrace" on fail
#gdb --args ./target5/BEX_E_cl.exe --buildFile build/extendedEc.txt --emitLang cc --singleCC true --emitFlag ccSgc

#nondebug
time target5/BEX_E_cl.exe --buildFile build/extendedEc.txt --emitLang cc --singleCC true --emitFlag ccSgc

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

#exit 0

#clang++ -DBEDCC_SGC=1 -o ./targetEc/BEX_E_cl.exe -pthread -ferror-limit=1 -std=c++11 ./targetEc/Base/target/cc/be/BEL_Base.cpp

#lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time clang++ -DBEDCC_SGC=1 -pthread -o ./targetEc/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./targetEc/Base/target/cc/be/BEL_Base.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targetEc/BEX_E_cl.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

