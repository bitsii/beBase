#!/bin/sh

java -classpath target5/Base/target/jv:system/jv abe.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy0 --buildPath cycle/target0 --emitLang jv
javac system/jv/abe/BELS_Base/*.java cycle/target0/Base/target/jv/abe/BEL_4_Base/*.java

java -classpath cycle/target0/Base/target/jv:system/jv abe.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy1 --buildPath cycle/target1 --emitLang jv
javac system/jv/abe/BELS_Base/*.java cycle/target1/Base/target/jv/abe/BEL_4_Base/*.java

java -classpath cycle/target1/Base/target/jv:system/jv abe.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy2 --buildPath cycle/target2 --emitLang jv
javac system/jv/abe/BELS_Base/*.java cycle/target2/Base/target/jv/abe/BEL_4_Base/*.java

java -classpath cycle/target2/Base/target/jv:system/jv abe.BEL_4_Base.BEL_4_Base --buildFile build/extendedEcEc.txt -deployPath=cycle/deployEc -buildPath=cycle/targetEc --emitLang jv
javac system/jv/abe/BELS_Base/*.java cycle/targetEc/Base/target/jv/abe/BEL_4_Base/*.java

java -classpath cycle/targetEc/Base/target/jv:system/jv abe.BEL_4_Base.BEL_4_Base "$*"

