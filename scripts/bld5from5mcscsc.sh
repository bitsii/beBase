#!/bin/bash

mono --debug target4/BEX_E_mcs.exe --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

csc -debug:pdbonly -warn:0 -out:target5/BEX_E_csc.exe system/cs/be/*.cs target5/Base/target/cs/be/*.cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
