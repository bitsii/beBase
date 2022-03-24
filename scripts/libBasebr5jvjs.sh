#!/bin/bash

rm -rf lib/br/js/BEL_Base_*

export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base source/base/Uses.be --buildFile build/libBasebr.txt --emitLang js --ownProcess false

#source/extended/LogSink.be

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

rm -rf lib/br/js
mkdir -p lib/br/js
mv lib/br/Base/target/js/be/*.syn lib/br/js
mv lib/br/Base/target/js/be/*.js lib/br/js
rm -rf lib/br/Base
