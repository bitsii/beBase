#!/bin/bash

time node target5/Base/target/js/be/BEL_Base.js --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang js

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
