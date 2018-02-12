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

mono --debug target5/BEX_E_mcs.exe --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy5 --buildPath target5
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#-O1, O2, O3

time clang++ -o ./target5/BEX_E_cl.exe -ferror-limit=1 -std=c++14 ./target5/Base/target/cc/be/BEX_E.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi


