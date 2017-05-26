#!/bin/bash

rm -rf targetEc/Base/target/jv

export CLASSPATH=target5/*

java be.BEX_E --buildFile build/extendedEc.txt --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

javac system/jv/be/*.java targetEc/Base/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

rm -f targetEc/BEL_system_be_jv.jar
cd system/jv
jar -cf ../../targetEc/BEL_system_be_jv.jar .
cd ../..

rm -f targetEc/BEX_E_be_jv.jar
cd targetEc/Base/target/jv
jar -cf ../../../BEX_E_be_jv.jar .
cd ../../../..

export CLASSPATH=targetEc/*

java be.BEX_E $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
