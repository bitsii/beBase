#!/bin/bash

rm -rf targetEc/Base/target/cc
mono --debug target5/BEL_4_Base_mcs.exe --buildFile build/extendedEc.txt --emitLang cc
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

