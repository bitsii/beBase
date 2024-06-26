
mkdir -p system
cd system
unzip -o ../boot5/BEL_system_be_mcs_macos.zip
cd ..

mkdir -p target5/Base/target
cd target5/Base/target
unzip -o ../../../boot5/BEX_E_be_mcs_macos.zip
cd ../../..

mcs -debug:pdbonly -warn:0 -out:target5/BEX_E_mcs.exe system/cs/be/*.cs target5/Base/target/cs/be/*.cs

./scripts/bld4cs.sh
./scripts/bld5cs.sh

