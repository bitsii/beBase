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

export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base --buildFile build/buildbuild.txt --emitLang js --deployPath deploy5 --buildPath target5

#--emitFlag jsStrInline

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi




