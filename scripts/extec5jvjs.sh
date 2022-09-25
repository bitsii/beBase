#!/bin/sh

rm -rf targetEc/Base/target/js

export CLASSPATH=target5/*

java be.BEL_Base  --buildFile build/extendedEc.txt --emitLang js

time node targetEc/Base/target/js/be/BEL_Base.js $*
