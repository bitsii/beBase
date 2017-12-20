#!/bin/bash

una=`uname -a`
case "$una" in
  *Msys*)
    export MAKNAME="mingw32-make"
    ;;
  *)
    export MAKNAME="make"
    ;;
esac

mono --debug target5/BEX_E_mcs.exe --buildFile build/buildbuild.txt --emitLang js --deployPath deploy5 --buildPath target5

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi




