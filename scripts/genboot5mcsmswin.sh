#!/bin/bash

mono --debug target5/BEL_4_Base_mcs.exe --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs --outputPlatform mswin

mkdir -p boot5
rm -f boot5/BEL_system_be_mcs_mswin.zip
cd system
zip -r ../boot5/BEL_system_be_mcs_mswin.zip cs
cd ..

rm -f boot5/BEL_4_Base_be_mcs_mswin.zip
cd target5/Base/target
zip -r ../../../boot5/BEL_4_Base_be_mcs_mswin.zip cs
cd ../../..
