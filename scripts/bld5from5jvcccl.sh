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

java be.BEX_E --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds true --deployPath deploy5 --buildPath target5
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

clang++ -o ./target5/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./target5/Base/target/cc/be/BEX_E.cpp


