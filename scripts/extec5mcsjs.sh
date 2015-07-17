#!/bin/sh

rm -rf targetEc/Base/target/cs
rm -f targetEc/BEL_4_Base_mcs.exe
mono target5/BEL_4_Base_mcs.exe --buildFile build/extendedEc.txt --emitLang js

node targetEc/Base/target/js/abe/BEL_4_Base/BEL_4_Base.js $*
