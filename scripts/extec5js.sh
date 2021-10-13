#!/bin/sh

rm -rf targetEc/Base/target/js

time node target5/Base/target/js/be/BEL_Base.js --buildFile build/extendedEc.txt --emitLang js

time node targetEc/Base/target/js/be/BEL_Base.js $*
