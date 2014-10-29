rmdir targetEc\Base\target\cs /s /q
del targetEc\BEL_4_Base_csc.exe
target5\BEL_4_Base_csc.exe --buildFile build\extendedEc.txt --emitLang cs
csc -debug /warn:0 -out:targetEc\BEL_4_Base_csc.exe /warn:0 system\cs\abe\BELS_Base\*.cs targetEc\Base\target\cs\abe\BEL_4_Base\*.cs
targetEc\BEL_4_Base_csc.exe %*
