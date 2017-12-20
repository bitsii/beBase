#!/bin/sh

rm -rf targetEc/Base/target/js

mono --debug target5/BEX_E_mcs.exe  --buildFile build/extendedEc.txt --emitLang js

time node targetEc/Base/target/js/be/BEX_E.js $*
