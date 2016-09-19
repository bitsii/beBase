REM del /s /q targetEc\Base\target\jv

java -classpath target5/BEL_system_be_jv.jar;target5/BEL_4_Base_be_jv.jar be.BEL_4_Base --buildFile build\extLib.txt --emitLang jv

if %errorlevel% neq 0 exit /b %errorlevel%

javac system\jv\be\*.java targetExtLib\Base\target\jv\be\*.java

if %errorlevel% neq 0 exit /b %errorlevel%

java -classpath target5/BEL_system_be_jv.jar;target5/BEL_4_Base_be_jv.jar;targetExtLib\Base\target\jv be.BEL_4_Base source/Base/Uses.be --buildFile build\extExe.txt -loadSyns=targetExtLib/Base/target/jv/be/BEL_4_Base.syn --emitLang jv

if %errorlevel% neq 0 exit /b %errorlevel%

javac -classpath system\jv;targetExtLib\Base\target\jv targetExtLib\Test\target\jv\be\*.java

if %errorlevel% neq 0 exit /b %errorlevel%

java -classpath system\jv;targetExtLib\Base\target\jv;targetExtLib\Test\target\jv be.BEL_4_Test %*

if %errorlevel% neq 0 exit /b %errorlevel%
