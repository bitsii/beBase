#!/bin/bash

mono --debug target5/BEL_4_Base_mcs.exe --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

mcs -debug:pdbonly -warn:0 -out:target4/BEL_4_Base_mcs.exe system/cs/be/BELS_Base/*.cs target4/Base/target/cs/be/BEL_4_Base/*.cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
