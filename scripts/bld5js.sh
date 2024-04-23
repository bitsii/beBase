#!/bin/bash

. scripts/bld4env.sh

$BEBLDR --buildFile build/buildbuild.txt --emitLang js --deployPath deploy5 --buildPath target5

#--emitFlag jsStrInline

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi




