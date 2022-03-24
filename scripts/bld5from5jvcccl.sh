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

export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy5 --buildPath target5 --emitFlag ccSgc
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#-O1, O2, O3 - most of the difference is O1

time clang++ -DBEDCC_SGC=1 -o ./target5/BEX_E_cl.exe -ferror-limit=1 -std=c++11 ./target5/Base/target/cc/be/BEL_Base.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi


