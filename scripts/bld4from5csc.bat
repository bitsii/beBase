target5\BEX_E_csc.exe --buildFile build\buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

call csc /debug:pdbonly /warn:0 -out:target4\BEX_E_csc.exe system\cs\be\*.cs target4\Base\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%
