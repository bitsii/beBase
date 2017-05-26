mono --debug target5\BEX_E_mcs.exe --buildFile build\extLib.txt --emitLang js

if %errorlevel% neq 0 exit /b %errorlevel%

mono --debug target5\BEX_E_mcs.exe source/Base/Uses.be -jsInclude=targetExtLib/Base/target/js/be/BEX_E.js --buildFile build\extExe.txt -loadSyns=targetExtLib/Base/target/js/be/BEX_E.syn --emitLang js

if %errorlevel% neq 0 exit /b %errorlevel%

node targetExtLib/Test/target/js/be/BEL_4_Test.js %*

if %errorlevel% neq 0 exit /b %errorlevel%
