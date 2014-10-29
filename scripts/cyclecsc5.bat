target5\BEL_4_Base_csc.exe --buildFile build\buildbuild.txt --deployPath cycle\deploy0 --buildPath cycle\target0 --emitLang cs
call csc /warn:0 -out:cycle\target0\BEL_4_Base_csc.exe system\cs\abe\BELS_Base\*.cs cycle\target0\Base\target\cs\abe\BEL_4_Base\*.cs

cycle\target0\BEL_4_Base_csc.exe --buildFile build\buildbuild.txt --deployPath cycle\deploy1 --buildPath cycle\target1 --emitLang cs
call csc /warn:0 -out:cycle\target1\BEL_4_Base_csc.exe system\cs\abe\BELS_Base\*.cs cycle\target1\Base\target\cs\abe\BEL_4_Base\*.cs

cycle\target1\BEL_4_Base_csc.exe --buildFile build\buildbuild.txt --deployPath cycle\deploy2 --buildPath cycle\target2 --emitLang cs
call csc /warn:0 -out:cycle\target2\BEL_4_Base_csc.exe system\cs\abe\BELS_Base\*.cs cycle\target2\Base\target\cs\abe\BEL_4_Base\*.cs

cycle\target2\BEL_4_Base_csc.exe --buildFile build\extendedEcEc.txt -deployPath=cycle\deployEc -buildPath=cycle\targetEc --emitLang cs
call csc /warn:0 -out:cycle\targetEc\BEL_4_Base_csc.exe system\cs\abe\BELS_Base\*.cs cycle\targetEc\Base\target\cs\abe\BEL_4_Base\*.cs

cycle\targetEc\BEL_4_Base_csc.exe %*
