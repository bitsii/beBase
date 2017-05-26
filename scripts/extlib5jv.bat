REM del /s /q targetEc\Base\target\jv

java -classpath target5/BEL_system_be_jv.jar;target5/BEX_E_be_jv.jar be.BEX_E --buildFile build\extLib.txt --emitLang jv

if %errorlevel% neq 0 exit /b %errorlevel%

javac system\jv\be\*.java targetExtLib\Base\target\jv\be\*.java

if %errorlevel% neq 0 exit /b %errorlevel%

java -classpath target5/BEL_system_be_jv.jar;target5/BEX_E_be_jv.jar;targetExtLib\Base\target\jv be.BEX_E source/Base/Uses.be --buildFile build\extExe.txt -loadSyns=targetExtLib/Base/target/jv/be/BEX_E.syn --emitLang jv

if %errorlevel% neq 0 exit /b %errorlevel%

javac -classpath system\jv;targetExtLib\Base\target\jv targetExtLib\Test\target\jv\be\*.java

if %errorlevel% neq 0 exit /b %errorlevel%

java -classpath system\jv;targetExtLib\Base\target\jv;targetExtLib\Test\target\jv be.BEL_4_Test %*

if %errorlevel% neq 0 exit /b %errorlevel%
