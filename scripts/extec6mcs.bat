rmdir targetEc\Base\target\cs /s /q
del targetEc\BEL_4_Base_mcs.exe
target6\BEL_4_Base_mcs.exe --buildFile build\extendedEc.txt --emitLang cs
call mcs /debug:pdbonly /warn:0 -out:targetEc\BEL_4_Base_mcs.exe /warn:0 system\cs\be\BELS_Base\*.cs targetEc\Base\target\cs\be\BEL_4_Base\*.cs
mono --debug targetEc\BEL_4_Base_mcs.exe %*
