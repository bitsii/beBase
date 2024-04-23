#!/bin/bash

. scripts/bld5env.sh

$BEBLDR --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang js

#\time --verbose
#--prof
#node --prof-process isolate-0x563fd88cb340-809577-v8.log > processed.txt

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
