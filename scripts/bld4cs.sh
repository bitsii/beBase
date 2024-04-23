#!/bin/bash

target5/BEX_E_csc.exe --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

csc -debug:pdbonly -warn:0 -out:target4/BEX_E_csc.exe system/cs/be/*.cs target4/Base/target/cs/be/*.cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
