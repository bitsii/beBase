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

rm -rf targets/min/Base/target/js/be

export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base -deployPath=targets/min -buildPath=targets/min --buildFile build/minBase.txt --emitLang js --emitFlag noSmap --emitFlag noRfl --mainClass Test:TestHelloWorld ../brace/source/baseTest/TestHelloWorld.be

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

time node targets/min/Base/target/js/be/BEL_Base.js $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

