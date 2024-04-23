#!/bin/bash

. scripts/bld5env.sh

rm -rf targets/tiny/Base/target/cc/be
rm -f targets/tiny/BEX_E.exe

$BEBLDR -deployPath=targets/tiny -buildPath=targets/tiny -cchImport=${BECCMACS} --emitFlag $BECCS --buildFile build/tinyBase.txt --emitLang cc --singleCC true --emitFlag ccSgc --emitFlag ccNoRtti --emitFlag noSmap --emitFlag noRfl --emitFlag noBet --emitFlag bemdSmall --mainClass Test:TestHelloWorld ../beBase/source/baseTest/TestHelloWorld.be

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

time $CC $CPFLAGS -o targets/tiny/BEX_E.exe ./targets/tiny/Base/target/cc/be/BEL_Base.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

time ./targets/tiny/BEX_E.exe

#sudo apt-get install valgrind kcachegrind graphviz
#valgrind --tool=callgrind ./targetEc/BEX_E_gn.exe

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

