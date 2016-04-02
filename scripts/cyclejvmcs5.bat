
call scripts\cyclejv5.bat

if %errorlevel% neq 0 exit /b %errorlevel%

call scripts\cyclemcs5.bat

if %errorlevel% neq 0 exit /b %errorlevel%
