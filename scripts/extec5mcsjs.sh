#!/bin/sh

rm -rf targetEc/Base/target/cs
rm -f targetEc/BEL_4_Base_mcs.exe
mono --debug target5/BEL_4_Base_mcs.exe --buildFile build/extendedEc.txt --emitLang js

node targetEc/Base/target/js/be/BEL_4_Base.js $*
