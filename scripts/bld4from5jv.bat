java -classpath target5\BEL_system_be_jv.jar;target5\BEL_4_Base_be_jv.jar be.BEL_4_Base.BEL_4_Base --buildFile build\buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang jv
javac system\jv\be\BELS_Base\*.java target4\Base\target\jv\be\BEL_4_Base\*.java

del target4\BEL_system_be_jv.jar
cd system\jv
jar -cf ..\..\target4\BEL_system_be_jv.jar .
cd ..\..

del target4\BEL_4_Base_be_jv.jar
cd target4\Base\target\jv
jar -cf ..\..\..\BEL_4_Base_be_jv.jar .
cd ..\..\..\..

cd system
del /s *.class
cd ..\target4
del /s *.class
cd ..
