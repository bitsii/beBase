#!/bin/sh

rm -rf targetEc/Base/target/js

export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base --buildFile build/extendedEc.txt --emitLang js --emitFlag noSmap

time node targetEc/Base/target/js/be/BEL_Base.js $*
