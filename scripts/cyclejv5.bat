
set startTime=%time%

java -classpath target5/BEL_system_be_jv.jar;target5/BEL_4_Base_be_jv.jar be.BEL_4_Base --buildFile build\buildbuild.txt --deployPath cycle\deploy0 --buildPath cycle\target0 --emitLang jv

if %errorlevel% neq 0 exit /b %errorlevel%

javac system\jv\be\*.java cycle\target0\Base\target\jv\be\*.java

if %errorlevel% neq 0 exit /b %errorlevel%

java -classpath cycle\target0\Base\target\jv;system\jv be.BEL_4_Base --buildFile build\buildbuild.txt --deployPath cycle\deploy1 --buildPath cycle\target1 --emitLang jv

if %errorlevel% neq 0 exit /b %errorlevel%

javac system\jv\be\*.java cycle\target1\Base\target\jv\be\*.java

if %errorlevel% neq 0 exit /b %errorlevel%

java -classpath cycle\target1\Base\target\jv;system\jv be.BEL_4_Base --buildFile build\buildbuild.txt --deployPath cycle\deploy2 --buildPath cycle\target2 --emitLang jv

if %errorlevel% neq 0 exit /b %errorlevel%

javac system\jv\be\*.java cycle\target2\Base\target\jv\be\*.java

if %errorlevel% neq 0 exit /b %errorlevel%

java -classpath cycle\target2\Base\target\jv;system\jv be.BEL_4_Base --buildFile build\extendedEcEc.txt -deployPath=cycle\deployEc -buildPath=cycle\targetEc --emitLang jv

if %errorlevel% neq 0 exit /b %errorlevel%

javac system\jv\be\*.java cycle\targetEc\Base\target\jv\be\*.java

if %errorlevel% neq 0 exit /b %errorlevel%

java -classpath cycle\targetEc\Base\target\jv;system\jv be.BEL_4_Base %* 

if %errorlevel% neq 0 exit /b %errorlevel%

echo Start Time: %startTime%
echo Finish Time: %time%
