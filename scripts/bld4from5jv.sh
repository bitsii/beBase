java -classpath target5/BEL_system_be_jv.jar:target5/BEL_4_Base_be_jv.jar be.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang jv
javac system/jv/be/BELS_Base/*.java target4/Base/target/jv/be/BEL_4_Base/*.java

rm -f target4/BEL_system_be_jv.jar
cd system/jv
jar -cf ../../target4/BEL_system_be_jv.jar .
cd ../..

rm -f target4/BEL_4_Base_be_jv.jar
cd target4/Base/target/jv
jar -cf ../../../BEL_4_Base_be_jv.jar .
cd ../../../..

find system -name "*.class" -exec rm {} \;
find target4 -name "*.class" -exec rm {} \;
