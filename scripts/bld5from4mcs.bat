target4\BEL_4_Base_mcs.exe --buildFile build\buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

call mcs /warn:0 -out:target5\BEL_4_Base_mcs.exe system\cs\be\BELS_Base\*.cs target5\Base\target\cs\be\BEL_4_Base\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%
