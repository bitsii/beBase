REM rmdir targetEc\Base\target\cs /s /q
del targetEc\BEL_4_Base_mcs.exe
mono --debug target5\BEL_4_Base_mcs.exe --buildFile build\extendedEc.txt --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

call mcs -debug:pdbonly /warn:0 -out:targetEc\BEL_4_Base_mcs.exe /warn:0 system\cs\be\*.cs targetEc\Base\target\cs\be\*.cs

mono --debug targetEc\BEL_4_Base_mcs.exe %*

if %errorlevel% neq 0 exit /b %errorlevel%
