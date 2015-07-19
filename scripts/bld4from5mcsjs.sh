#!/bin/sh

mono --debug target5/BEL_4_Base_mcs.exe --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang js
