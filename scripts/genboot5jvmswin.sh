#!/bin/bash

export CLASSPATH=target5/*

java be.BEL_Base --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang jv --outputPlatform mswin

find system -name "*.class" -exec rm {} \;
find target5 -name "*.class" -exec rm {} \;

mkdir -p boot5
rm -f boot5/BEL_system_be_jv_mswin.zip
cd system
zip -r ../boot5/BEL_system_be_jv_mswin.zip jv
cd ..

rm -f boot5/BEX_E_be_jv_mswin.zip
cd target5/Base/target
zip -r ../../../boot5/BEX_E_be_jv_mswin.zip jv
cd ../../..
