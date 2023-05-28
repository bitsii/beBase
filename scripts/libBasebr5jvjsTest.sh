#!/bin/bash

rm -rf targetLibBasebrTest

export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base source/base/Uses.be --buildFile build/libBasebrTest.txt -loadSyns=lib/br/js/BEL_Base.syn -initLib=Base --emitLang js source/baseTest/TestHelloWorld.be

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

node targetLibBasebrTest/Test/target/js/be/BEL_Test.js $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
