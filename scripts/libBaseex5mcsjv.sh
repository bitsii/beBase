#!/bin/bash

rm -rf lib/ex/jv/BEL_Base_*

time mono --debug target5/BEX_E_mcs.exe source/base/Uses.be --buildFile build/libBaseex.txt --emitLang jv --doMain false source/extended/LogSink.be

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

javac system/jv/be/*.java lib/ex/Base/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

rm -rf lib/ex/jv
mkdir -p lib/ex/jv
mv lib/ex/Base/target/jv/be/*.ids lib/ex/jv
mv lib/ex/Base/target/jv/be/*.syn lib/ex/jv
rm -f lib/ex/Base/target/jv/be/*.java

rm -f lib/ex/jv/BEL_Base.jar
cd lib/ex/Base/target/jv
jar -cf ../../../../ex/jv/BEL_Base.jar .
cd ../../../../..
rm -rf lib/ex/Base

rm -f lib/ex/jv/BES_System.jar
cd system/jv
jar -cf ../../lib/ex/jv/BES_System.jar .
cd ../..
