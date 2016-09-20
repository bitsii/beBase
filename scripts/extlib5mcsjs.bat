mono --debug target5\BEL_4_Base_mcs.exe --buildFile build\extLib.txt --emitLang js

if %errorlevel% neq 0 exit /b %errorlevel%

mono --debug target5\BEL_4_Base_mcs.exe source/Base/Uses.be -jsInclude=targetExtLib/Base/target/js/be/BEL_4_Base.js --buildFile build\extExe.txt -loadSyns=targetExtLib/Base/target/js/be/BEL_4_Base.syn --emitLang js

if %errorlevel% neq 0 exit /b %errorlevel%

node targetExtLib/Test/target/js/be/BEL_4_Test.js %*

if %errorlevel% neq 0 exit /b %errorlevel%
