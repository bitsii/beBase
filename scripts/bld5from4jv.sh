java -classpath target4/BEL_system_be_jv.jar:target4/BEL_4_Base_be_jv.jar be.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang jv
javac system/jv/be/BELS_Base/*.java target5/Base/target/jv/be/BEL_4_Base/*.java

rm -f target5/BEL_system_be_jv.jar
cd system/jv
jar -cf ../../target5/BEL_system_be_jv.jar .
cd ../..

rm -f target5/BEL_4_Base_be_jv.jar
cd target5/Base/target/jv
jar -cf ../../../BEL_4_Base_be_jv.jar .
cd ../../../..

find system -name "*.class" -exec rm {} \;
find target5 -name "*.class" -exec rm {} \;
