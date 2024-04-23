#!/bin/bash

. scripts/bld5env.sh

rm -rf target4/Base/target/cc ./target4/BEX_E.exe

#start with "perf record" to profile, see results with "perf report"
#to debug / get stack gdb --args 
#catch throw
#run

#debug "run" to get going, "backtrace" on fail
#gdb --args ./target5/BEX_E_cl.exe --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy4 --buildPath target4 --emitFlag ccSgc

#nondebug
$BEBLDR -cchImport=${BECCMACS} --emitFlag $BECCS --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy4 --buildPath target4 --emitFlag ccSgc

#sudo apt-get install valgrind kcachegrind graphviz
#after just run kcachegrind
#time valgrind --tool=callgrind ./target5/BEX_E_cl.exe --buildFile build/buildbuild.txt --emitLang cc --singleCC true --saveIds false --deployPath deploy4 --buildPath target4 --emitFlag ccSgc

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time $CC $CPFLAGS -o ./target4/BEX_E.exe ./target4/Base/target/cc/be/BEL_Base.cpp


