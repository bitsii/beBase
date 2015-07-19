target5\BEL_4_Base_csc.exe --buildFile build\buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang cs
call csc /debug:pdbonly /warn:0 -out:target4\BEL_4_Base_csc.exe system\cs\be\BELS_Base\*.cs target4\Base\target\cs\be\BEL_4_Base\*.cs
