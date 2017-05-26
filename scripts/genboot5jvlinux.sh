#!/bin/bash

export CLASSPATH=target5/*

java be.BEX_E --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang jv --outputPlatform linux

find system -name "*.class" -exec rm {} \;
find target5 -name "*.class" -exec rm {} \;

mkdir -p boot5
rm -f boot5/BEL_system_be_jv_linux.zip
cd system
zip -r ../boot5/BEL_system_be_jv_linux.zip jv
cd ..

rm -f boot5/BEX_E_be_jv_linux.zip
cd target5/Base/target
zip -r ../../../boot5/BEX_E_be_jv_linux.zip jv
cd ../../..
