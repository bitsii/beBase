mono --debug target5\BEL_4_Base_mcs.exe --buildFile build\buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang cs %*

if %errorlevel% neq 0 exit /b %errorlevel%

call mcs -debug:pdbonly /warn:0 -out:target4\BEL_4_Base_mcs.exe system\cs\be\BELS_Base\*.cs target4\Base\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%
