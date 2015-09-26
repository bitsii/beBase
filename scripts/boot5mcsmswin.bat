mkdir system
cd system
unzip -o ..\boot5\BEL_system_be_mcs_mswin.zip
cd ..

mkdir target5\Base\target
cd target5\Base\target
unzip -o ..\..\..\boot5\BEL_4_Base_be_mcs_mswin.zip
cd ..\..\..

call mcs /warn:0 -out:target5\BEL_4_Base_mcs.exe system\cs\be\BELS_Base\*.cs target5\Base\target\cs\be\BEL_4_Base\*.cs

rem call scripts\bld4from5mcs.bat
