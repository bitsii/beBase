#!/bin/bash

. scripts/bld5env.sh

rm -rf targets/tiny/Base/target/js/be

$BEBLDR -deployPath=targets/tiny -buildPath=targets/tiny --buildFile build/tinyBase.txt --emitLang js --emitFlag noSmap --emitFlag noRfl --mainClass Test:TestHelloWorld ../beBase/source/baseTest/TestHelloWorld.be

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC1=`date +%s`

time node targets/tiny/Base/target/js/be/BEL_Base.js $*

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

CYC2=`date +%s`

expr \( $CYC2 - $CYC1 \)

