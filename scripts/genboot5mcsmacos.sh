#!/bin/bash

mono --debug target5/BEX_E_mcs.exe --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs --outputPlatform macos

mkdir -p boot5
rm -f boot5/BEL_system_be_mcs_macos.zip
cd system
zip -r ../boot5/BEL_system_be_mcs_macos.zip cs
cd ..

rm -f boot5/BEX_E_be_mcs_macos.zip
cd target5/Base/target
zip -r ../../../boot5/BEX_E_be_mcs_macos.zip cs
cd ../../..
