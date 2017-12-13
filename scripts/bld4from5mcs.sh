#!/bin/bash

time mono --debug target5/BEX_E_mcs.exe --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

mcs -debug:pdbonly -warn:0 -out:target4/BEX_E_mcs.exe system/cs/be/*.cs target4/Base/target/cs/be/*.cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
