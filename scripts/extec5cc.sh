#!/bin/bash

. scripts/bld5env.sh

#rm -rf targetEc/Base/target/cc

$BEBLDR -cchImport=${BECCMACS} --emitFlag $BECCS --buildFile build/extendedEc.txt --emitLang cc --singleCC true --emitFlag ccSgc --emitFlag bemdSmall

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

time $CC $CPFLAGS -o targetEc/BEX_E.exe ./targetEc/Base/target/cc/be/BEL_Base.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targetEc/BEX_E.exe

#sudo apt-get install valgrind kcachegrind graphviz
#valgrind --tool=callgrind ./targetEc/BEX_E_gn.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

