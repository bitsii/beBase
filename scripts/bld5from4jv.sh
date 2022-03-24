#!/bin/bash

export CLASSPATH=target4/*
java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

javac system/jv/be/*.java target5/Base/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

rm -f target5/BEL_system_be_jv.jar
cd system/jv
jar -cf ../../target5/BEL_system_be_jv.jar .
cd ../..

rm -f target5/BEX_E_be_jv.jar
cd target5/Base/target/jv
jar -cf ../../../BEX_E_be_jv.jar .
cd ../../../..

find system -name "*.class" -exec rm {} \;
find target5 -name "*.class" -exec rm {} \;
