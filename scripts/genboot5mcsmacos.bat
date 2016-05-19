mono --debug target5\BEL_4_Base_mcs.exe --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs --outputPlatform macos

mkdir boot5
del boot5\BEL_system_be_mcs_macos.zip
cd system
zip -r ..\boot5\BEL_system_be_mcs_macos.zip cs
cd ..

del boot5\BEL_4_Base_be_mcs_macos.zip
cd target5\Base\target
zip -r ..\..\..\boot5\BEL_4_Base_be_mcs_macos.zip cs
cd ..\..\..
