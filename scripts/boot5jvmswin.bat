mkdir system
cd system
unzip -o ..\boot5\BEL_system_be_jv_mswin.zip
cd ..

mkdir target5\Base\target
cd target5\Base\target
unzip -o ..\..\..\boot5\BEL_4_Base_be_jv_mswin.zip
cd ..\..\..

javac system\jv\be\*.java target5\Base\target\jv\be\*.java

del target5\BEL_system_be_jv.jar
cd system\jv
jar -cf ..\..\target5\BEL_system_be_jv.jar .
cd ..\..

del target5\BEL_4_Base_be_jv.jar
cd target5\Base\target\jv
jar -cf ..\..\..\BEL_4_Base_be_jv.jar .
cd ..\..\..\..

cd system
del /s *.class
cd ..\target5
del /s *.class
cd ..

call scripts\bld4from5jv.bat
