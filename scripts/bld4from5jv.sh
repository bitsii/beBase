#!/bin/bash

export CLASSPATH=target5/*

#-XX:+UseSerialGC good
#-XX:TieredStopAtLevel=1 good

time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

javac system/jv/be/*.java target4/Base/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

rm -f target4/BEL_system_be_jv.jar
cd system/jv
jar -cf ../../target4/BEL_system_be_jv.jar .
cd ../..

rm -f target4/BEX_E_be_jv.jar
cd target4/Base/target/jv
jar -cf ../../../BEX_E_be_jv.jar .
cd ../../../..

find system -name "*.class" -exec rm {} \;
find target4 -name "*.class" -exec rm {} \;
