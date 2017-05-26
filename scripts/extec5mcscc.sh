#!/bin/bash

rm -rf targetEc/Base/target/cc
mono --debug target5/BEX_E_mcs.exe --buildFile build/extendedEc.txt --emitLang cc

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

clang++ -std=c++11 ./targetEc/Base/target/cc/be/BEH_4_Base.hpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

g++ -std=c++11 ./targetEc/Base/target/cc/be/BEH_4_Base.hpp


