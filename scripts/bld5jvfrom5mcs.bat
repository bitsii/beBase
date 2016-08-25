target5\BEL_4_Base_mcs.exe --buildFile build\buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang jv %*

if %errorlevel% neq 0 exit /b %errorlevel%

javac system\jv\be\BELS_Base\*.java target5\Base\target\jv\be\BEL_4_Base\*.java

if %errorlevel% neq 0 exit /b %errorlevel%

del target5\BEL_system_be_jv.jar
cd system\jv
jar -cf ..\..\target5\BEL_system_be_jv.jar .
cd ..\..

del target5\BEL_4_Base_be_jv.jar
cd target5\Base\target\jv
jar -cf ..\..\..\BEL_4_Base_be_jv.jar .
cd ..\..\..\..

cd system
del /s *.class
cd ..\target5
del /s *.class
cd ..
