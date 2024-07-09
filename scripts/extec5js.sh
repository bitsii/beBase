#!/bin/sh

. scripts/bld5env.sh

rm -rf targetEc/Base/target/js

$BEBLDR --buildFile build/extendedEc.txt --emitLang js

#time node --trace-deprecation targetEc/Base/target/js/be/BEL_Base.js $*

time node targetEc/Base/target/js/be/BEL_Base.js $*