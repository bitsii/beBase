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

time target5/BEX_E_cl.exe -deployPath=targets/min -buildPath=targets/min --buildFile build/minBase.txt --emitLang cc --singleCC true --emitFlag ccSgc --mainClass Test:TestHelloWorld ../brace/source/baseTest/TestHelloWorld.be

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

time clang++ -DBEDCC_SGC=1 -o targets/min/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./targets/min/Base/target/cc/be/BEL_Base.cpp


lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targets/min/BEX_E_cl.exe

#sudo apt-get install valgrind kcachegrind graphviz
#valgrind --tool=callgrind ./targetEc/BEX_E_gn.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

