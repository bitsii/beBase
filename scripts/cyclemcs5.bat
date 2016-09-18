
set startTime=%time%

target5\BEL_4_Base_mcs.exe --buildFile build\buildbuild.txt --deployPath cycle\deploy0 --buildPath cycle\target0 --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

call mcs /debug:pdbonly /warn:0 -out:cycle\target0\BEL_4_Base_mcs.exe system\cs\be\*.cs cycle\target0\Base\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%

mono --debug cycle\target0\BEL_4_Base_mcs.exe --buildFile build\buildbuild.txt --deployPath cycle\deploy1 --buildPath cycle\target1 --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

call mcs /debug:pdbonly /warn:0 -out:cycle\target1\BEL_4_Base_mcs.exe system\cs\be\*.cs cycle\target1\Base\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%

mono --debug cycle\target1\BEL_4_Base_mcs.exe --buildFile build\buildbuild.txt --deployPath cycle\deploy2 --buildPath cycle\target2 --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

call mcs /debug:pdbonly /warn:0 -out:cycle\target2\BEL_4_Base_mcs.exe system\cs\be\*.cs cycle\target2\Base\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%

mono --debug cycle\target2\BEL_4_Base_mcs.exe --buildFile build\extendedEcEc.txt -deployPath=cycle\deployEc -buildPath=cycle\targetEc --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

call mcs /debug:pdbonly /warn:0 -out:cycle\targetEc\BEL_4_Base_mcs.exe system\cs\be\*.cs cycle\targetEc\Base\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%

mono --debug cycle\targetEc\BEL_4_Base_mcs.exe %*

if %errorlevel% neq 0 exit /b %errorlevel%

echo Start Time: %startTime%
echo Finish Time: %time%
