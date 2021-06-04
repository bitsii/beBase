#!/bin/bash

CYC0=`date +%s`

export CLASSPATH=target5/*

java be.BEL_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy0 --buildPath cycle/target0 --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

export CLASSPATH=cycle/target0/*
rm -f cycle/target0/BEL_system_be_jv.jar
rm -f cycle/target0/BEX_E_be_jv.jar

javac system/jv/be/*.java cycle/target0/Base/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

cd system/jv
jar -cf ../../cycle/target0/BEL_system_be_jv.jar .
cd ../..

cd cycle/target0/Base/target/jv
jar -cf ../../../BEX_E_be_jv.jar .
cd ../../../../..

CYC2=`date +%s`

java be.BEL_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy1 --buildPath cycle/target1 --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC3=`date +%s`

export CLASSPATH=cycle/target1/*
rm -f cycle/target1/BEL_system_be_jv.jar
rm -f cycle/target1/BEX_E_be_jv.jar

javac system/jv/be/*.java cycle/target1/Base/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

cd system/jv
jar -cf ../../cycle/target1/BEL_system_be_jv.jar .
cd ../..

cd cycle/target1/Base/target/jv
jar -cf ../../../BEX_E_be_jv.jar .
cd ../../../../..

CYC4=`date +%s`

java be.BEL_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy2 --buildPath cycle/target2 --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC5=`date +%s`

export CLASSPATH=cycle/target2/*
rm -f cycle/target2/BEL_system_be_jv.jar
rm -f cycle/target2/BEX_E_be_jv.jar

javac system/jv/be/*.java cycle/target2/Base/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

cd system/jv
jar -cf ../../cycle/target2/BEL_system_be_jv.jar .
cd ../..

cd cycle/target2/Base/target/jv
jar -cf ../../../BEX_E_be_jv.jar .
cd ../../../../..

CYC6=`date +%s`

java be.BEL_Base --buildFile build/extendedEcEc.txt -deployPath=cycle/deployEc -buildPath=cycle/targetEc --emitLang jv

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC7=`date +%s`

export CLASSPATH=cycle/targetEc/*
rm -f cycle/targetEc/BEL_system_be_jv.jar
rm -f cycle/targetEc/BEX_E_be_jv.jar

javac system/jv/be/*.java cycle/targetEc/Base/target/jv/be/*.java

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

cd system/jv
jar -cf ../../cycle/targetEc/BEL_system_be_jv.jar .
cd ../..

cd cycle/targetEc/Base/target/jv
jar -cf ../../../BEX_E_be_jv.jar .
cd ../../../../..

CYC8=`date +%s`

java be.BEL_Base $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC9=`date +%s`

find system -name "*.class" -exec rm {} \;

expr \( $CYC1 - $CYC0 \) + \( $CYC3 - $CYC2 \) + \( $CYC5 - $CYC4 \) + \( $CYC7 - $CYC6 \) + \( $CYC9 - $CYC8 \)
