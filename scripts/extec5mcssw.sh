#!/bin/bash

rm -rf targetEc/Base/target/sw
rm -f targetEc/BEL_4_Base_mcs.exe
mono --debug target5/BEL_4_Base_mcs.exe --buildFile build/extendedEc.txt --emitLang sw
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

