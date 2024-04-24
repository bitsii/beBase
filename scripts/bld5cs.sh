#!/bin/bash

. scripts/bld4env.sh

$BEBLDR --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

#mcs -debug:pdbonly -warn:0 -out:target5/BEX_E_mcs.exe system/cs/be/*.cs target5/Base/target/cs/be/*.cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
