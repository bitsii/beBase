#!/bin/sh

java -classpath target5/BEL_system_be_jv.jar:target5/BEL_4_Base_be_jv.jar be.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy0 --buildPath cycle/target0 --emitLang jv
javac system/jv/be/BELS_Base/*.java cycle/target0/Base/target/jv/be/BEL_4_Base/*.java

java -classpath cycle/target0/Base/target/jv:system/jv be.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy1 --buildPath cycle/target1 --emitLang jv
javac system/jv/be/BELS_Base/*.java cycle/target1/Base/target/jv/be/BEL_4_Base/*.java

java -classpath cycle/target1/Base/target/jv:system/jv be.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath cycle/deploy2 --buildPath cycle/target2 --emitLang jv
javac system/jv/be/BELS_Base/*.java cycle/target2/Base/target/jv/be/BEL_4_Base/*.java

java -classpath cycle/target2/Base/target/jv:system/jv be.BEL_4_Base.BEL_4_Base --buildFile build/extendedEcEc.txt -deployPath=cycle/deployEc -buildPath=cycle/targetEc --emitLang jv
javac system/jv/be/BELS_Base/*.java cycle/targetEc/Base/target/jv/be/BEL_4_Base/*.java

java -classpath cycle/targetEc/Base/target/jv:system/jv be.BEL_4_Base.BEL_4_Base $*

