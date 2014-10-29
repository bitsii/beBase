target4\BEL_4_Base_csc.exe --buildFile build\buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs
call csc /warn:0 -out:target5\BEL_4_Base_csc.exe system\cs\abe\BELS_Base\*.cs target5\Base\target\cs\abe\BEL_4_Base\*.cs
