target4\BEX_E_csc.exe --buildFile build\buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

call csc /debug:pdbonly /warn:0 -out:target5\BEX_E_csc.exe system\cs\be\*.cs target5\Base\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%
