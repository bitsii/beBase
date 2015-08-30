#!/bin/sh

CYC0=`date +%s`

java -classpath target5/BEL_system_be_jv.jar:target5/BEL_4_Base_be_jv.jar be.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy0 --buildPath cycle/target0 --emitLang jv

CYC1=`date +%s`

javac system/jv/be/BELS_Base/*.java cycle/target0/Base/target/jv/be/BEL_4_Base/*.java

CYC2=`date +%s`

java -classpath cycle/target0/Base/target/jv:system/jv be.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy1 --buildPath cycle/target1 --emitLang jv

CYC3=`date +%s`

javac system/jv/be/BELS_Base/*.java cycle/target1/Base/target/jv/be/BEL_4_Base/*.java

CYC4=`date +%s`

java -classpath cycle/target1/Base/target/jv:system/jv be.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy2 --buildPath cycle/target2 --emitLang jv

CYC5=`date +%s`

javac system/jv/be/BELS_Base/*.java cycle/target2/Base/target/jv/be/BEL_4_Base/*.java

CYC6=`date +%s`

java -classpath cycle/target2/Base/target/jv:system/jv be.BEL_4_Base.BEL_4_Base --buildFile build/extendedEcEc.txt -deployPath=cycle/deployEc -buildPath=cycle/targetEc --emitLang jv

CYC7=`date +%s`

javac system/jv/be/BELS_Base/*.java cycle/targetEc/Base/target/jv/be/BEL_4_Base/*.java

CYC8=`date +%s`

java -classpath cycle/targetEc/Base/target/jv:system/jv be.BEL_4_Base.BEL_4_Base $*

CYC9=`date +%s`

find system -name "*.class" -exec rm {} \;

expr \( $CYC1 - $CYC0 \) + \( $CYC3 - $CYC2 \) + \( $CYC5 - $CYC4 \) + \( $CYC7 - $CYC6 \) + \( $CYC9 - $CYC8 \)
