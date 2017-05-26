REM rmdir targetEc\Base\target\cs /s /q
del targetExtLib\BEX_E_mcs.*
mono --debug target5\BEX_E_mcs.exe --buildFile build\extLib.txt --emitLang cs

if %errorlevel% neq 0 exit /b %errorlevel%

call mcs -debug:pdbonly /warn:0 -t:library -out:targetExtLib\BEX_E_mcs.dll /warn:0 system\cs\be\*.cs targetExtLib\Base\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%

mono --debug target5\BEX_E_mcs.exe source/Base/Uses.be --buildFile build\extExe.txt -loadSyns=targetExtLib/Base/target/cs/be/BEX_E.syn --emitLang cs

call mcs -debug:pdbonly /warn:0 -r:targetExtLib\BEX_E_mcs.dll -out:targetExtLib\BEL_4_Test_mcs.exe /warn:0 targetExtLib\Test\target\cs\be\*.cs

if %errorlevel% neq 0 exit /b %errorlevel%

mono --debug targetExtLib\BEL_4_Test_mcs.exe %*

if %errorlevel% neq 0 exit /b %errorlevel%
