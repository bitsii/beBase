REM rmdir targetEc\Base\target\cs /s /q
del targetExtLib\BEL_4_Base_mcs.*
mono --debug target5\BEL_4_Base_mcs.exe --buildFile build\extLib.txt --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

call mcs -debug:pdbonly /warn:0 -t:library -out:targetExtLib\BEL_4_Base_mcs.dll /warn:0 system\cs\be\*.cs targetExtLib\Base\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%

mono --debug target5\BEL_4_Base_mcs.exe source/Base/Uses.be --buildFile build\extExe.txt --emitLang cs

call mcs -debug:pdbonly /warn:0 -r:targetExtLib\BEL_4_Base_mcs.dll -out:targetExtLib\BEL_4_Test_mcs.exe /warn:0 targetExtLib\Test\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%

mono --debug targetExtLib\BEL_4_Test_mcs.exe %*

if %errorlevel% neq 0 exit /b %errorlevel%
