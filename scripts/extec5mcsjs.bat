
target5\BEL_4_Base_mcs.exe --buildFile build\extendedEc.txt --emitLang js

if %errorlevel% neq 0 exit /b %errorlevel%

node targetEc/Base/target/js/be/BEL_4_Base.js %*

