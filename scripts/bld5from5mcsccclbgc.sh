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

rm -rf target5/Base/target/cc ./target5/BEX_E_cl.exe

mono --debug target5/BEX_E_mcs.exe --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy5 --buildPath target5 --emitFlag ccBgc --emitFlag ccPt
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#-O1, O2, O3 - most of the difference is O1, as fast as jv

#sudo apt-get install libgc-dev
time clang++ -DBEDCC_PT=1 -DBEDCC_BGC=1 -pthread -o ./target5/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./target5/Base/target/cc/be/BEL_Base.cpp /usr/lib/x86_64-linux-gnu/libgc.a

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi


