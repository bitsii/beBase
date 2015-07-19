target6\BEL_4_Base_mcs.exe --buildFile build\buildbuild.txt --deployPath cycle\deploy0 --buildPath cycle\target0 --emitLang cs
call mcs /debug:pdbonly /warn:0 -out:cycle\target0\BEL_4_Base_mcs.exe system\cs\be\BELS_Base\*.cs cycle\target0\Base\target\cs\be\BEL_4_Base\*.cs

cycle\target0\BEL_4_Base_mcs.exe --buildFile build\buildbuild.txt --deployPath cycle\deploy1 --buildPath cycle\target1 --emitLang cs
call mcs /debug:pdbonly /warn:0 -out:cycle\target1\BEL_4_Base_mcs.exe system\cs\be\BELS_Base\*.cs cycle\target1\Base\target\cs\be\BEL_4_Base\*.cs

cycle\target1\BEL_4_Base_mcs.exe --buildFile build\buildbuild.txt --deployPath cycle\deploy2 --buildPath cycle\target2 --emitLang cs
call mcs /debug:pdbonly /warn:0 -out:cycle\target2\BEL_4_Base_mcs.exe system\cs\be\BELS_Base\*.cs cycle\target2\Base\target\cs\be\BEL_4_Base\*.cs

cycle\target2\BEL_4_Base_mcs.exe --buildFile build\extendedEcEc.txt -deployPath=cycle\deployEc -buildPath=cycle\targetEc --emitLang cs
call mcs /debug:pdbonly /warn:0 -out:cycle\targetEc\BEL_4_Base_mcs.exe system\cs\be\BELS_Base\*.cs cycle\targetEc\Base\target\cs\be\BEL_4_Base\*.cs

cycle\targetEc\BEL_4_Base_mcs.exe %*
