#!/bin/sh

mono --debug target5/BEX_E_mcs.exe --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang js
