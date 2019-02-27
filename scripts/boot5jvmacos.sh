
mkdir -p system
cd system
unzip -o ../boot5/BEL_system_be_jv_macos.zip
cd ..

mkdir -p target5/Base/target
cd target5/Base/target
unzip -o ../../../boot5/BEX_E_be_jv_macos.zip
cd ../../..

javac system/jv/be/*.java target5/Base/target/jv/be/*.java

rm -f target5/BEL_system_be_jv.jar
cd system/jv
jar -cf ../../target5/BEL_system_be_jv.jar .
cd ../..

rm -f target5/BEX_E_be_jv.jar
cd target5/Base/target/jv
jar -cf ../../../BEX_E_be_jv.jar .
cd ../../../..

find system -name "*.class" -exec rm {} \;
find target5 -name "*.class" -exec rm {} \;

./scripts/bld4from5jv.sh
./scripts/bld5from4jv.sh
