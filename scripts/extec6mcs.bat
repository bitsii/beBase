rmdir targetEc\Base\target\cs /s /q
del targetEc\BEL_4_Base_mcs.exe
target6\BEL_4_Base_mcs.exe --buildFile build\extendedEc.txt --emitLang cs
call mcs -debug /warn:0 -out:targetEc\BEL_4_Base_mcs.exe /warn:0 system\cs\abe\BELS_Base\*.cs targetEc\Base\target\cs\abe\BEL_4_Base\*.cs
mono --debug targetEc\BEL_4_Base_mcs.exe %*
