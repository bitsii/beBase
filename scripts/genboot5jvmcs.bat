
call scripts\genboot5jvlinux.bat

if %errorlevel% neq 0 exit /b %errorlevel%

call scripts\genboot5jvmswin.bat

if %errorlevel% neq 0 exit /b %errorlevel%

call scripts\genboot5mcslinux.bat

if %errorlevel% neq 0 exit /b %errorlevel%

call scripts\genboot5mcsmswin.bat

if %errorlevel% neq 0 exit /b %errorlevel%

