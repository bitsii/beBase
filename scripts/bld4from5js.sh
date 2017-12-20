#!/bin/bash

time node target5/Base/target/js/be/BEX_E.js --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang js

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
