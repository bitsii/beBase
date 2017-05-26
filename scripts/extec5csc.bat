rmdir targetEc\Base\target\cs /s /q
del targetEc\BEX_E_csc.exe
target5\BEX_E_csc.exe --buildFile build\extendedEc.txt --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

csc -debug /warn:0 -out:targetEc\BEX_E_csc.exe /warn:0 system\cs\be\BELS_Base\*.cs targetEc\Base\target\cs\be\BEX_E\*.cs
targetEc\BEX_E_csc.exe %*

if %errorlevel% neq 0 exit /b %errorlevel%
