target5\BEL_4_Base_mcs.exe --buildFile build\buildbuild.txt --deployPath deploy6 --buildPath target6 --emitLang cs
call mcs /warn:0 -out:target6\BEL_4_Base_mcs.exe system\cs\abe\BELS_Base\*.cs target6\Base\target\cs\abe\BEL_4_Base\*.cs
