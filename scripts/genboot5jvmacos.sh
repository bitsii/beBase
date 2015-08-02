java -classpath target5/BEL_system_be_jv.jar:target5/BEL_4_Base_be_jv.jar be.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang jv --outputPlatform macos

find system -name "*.class" -exec rm {} \;
find target5 -name "*.class" -exec rm {} \;

mkdir -p boot5
rm -f boot5/BEL_system_be_jv_macos.zip
cd system
zip -r ../boot5/BEL_system_be_jv_macos.zip jv
cd ..

rm -f boot5/BEL_4_Base_be_jv_macos.zip
cd target5/Base/target
zip -r ../../../boot5/BEL_4_Base_be_jv_macos.zip jv
cd ../../..
