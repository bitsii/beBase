rmdir targetEc\Base\target\cs /s /q
del targetEc\BEL_4_Base_csc.exe
target5\BEL_4_Base_csc.exe --buildFile build\extendedEc.txt --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

csc -debug /warn:0 -out:targetEc\BEL_4_Base_csc.exe /warn:0 system\cs\be\BELS_Base\*.cs targetEc\Base\target\cs\be\BEL_4_Base\*.cs
targetEc\BEL_4_Base_csc.exe %*

if %errorlevel% neq 0 exit /b %errorlevel%
