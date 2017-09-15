#!/bin/sh

rm -rf targetEc/Base/target/js

export CLASSPATH=target5/*

java be.BEX_E  --buildFile build/extendedEc.txt --emitLang js

node targetEc/Base/target/js/be/BEX_E.js $*
