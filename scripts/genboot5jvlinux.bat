java -classpath target5\BEL_system_be_jv.jar;target5\BEL_4_Base_be_jv.jar be.BEL_4_Base.BEL_4_Base --buildFile build\buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang jv --outputPlatform linux

cd system
del /s *.class
cd ..\target5
del /s *.class
cd ..

mkdir boot5
del boot5\BEL_system_be_jv_linux.zip
cd system
zip -r ..\boot5\BEL_system_be_jv_linux.zip jv
cd ..

del boot5\BEL_4_Base_be_jv_linux.zip
cd target5\Base\target
zip -r ..\..\..\boot5\BEL_4_Base_be_jv_linux.zip jv
cd ..\..\..
