#!/bin/bash

rm -rf lib/jv/BEL_Base_*

time mono --debug target5/BEX_E_mcs.exe source/base/Uses.be --buildFile build/libBasebr.txt --emitLang jv --ownProcess false --doMain false source/extended/LogSink.be

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

javac system/jv/be/*.java lib/Base/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

rm -rf lib/jv
mkdir lib/jv
mv lib/Base/target/jv/be/*.ids lib/jv
mv lib/Base/target/jv/be/*.syn lib/jv
rm -f lib/Base/target/jv/be/*.java

rm -f lib/jv/BEL_Base.jar
cd lib/Base/target/jv
jar -cf ../../../jv/BEL_Base.jar .
cd ../../../..
rm -rf lib/Base

rm -f lib/jv/BES_System.jar
cd system/jv
jar -cf ../../lib/jv/BES_System.jar .
cd ../..
