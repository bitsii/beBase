#!/bin/bash

una=`uname -a`

rm -rf targetLibBaseexTest

export CLASSPATH=target5/*
time java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base source/base/Uses.be --buildFile build/libBaseexTest.txt -loadSyns=lib/ex/jv/BEL_Base.syn -loadIds=lib/ex/jv/BEL_Base -initLib=Base --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

case "$una" in
  *Msys*)
    export CLASSPATH="lib/ex/jv/BES_System.jar;lib/ex/jv/BEL_Base.jar;targetLibBaseexTest/Test/target/jv"
    ;;
  *)
    export CLASSPATH="lib/ex/jv/BES_System.jar:lib/ex/jv/BEL_Base.jar:targetLibBaseexTest/Test/target/jv"
    ;;
esac

javac targetLibBaseexTest/Test/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

java be.BEL_Test $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
