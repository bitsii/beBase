#!/bin/bash

. scripts/bld5env.sh

rm -rf target4/Base/target/cs
rm -rf target4/bin

$BEBLDR --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

cp system/BEX_DN/BEX_DN.csproj target4/Base/target/cs/be
cp system/cs/be/BE* target4/Base/target/cs/be/
cd target4/Base/target/cs/be/

dotnet build
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

mv bin ../../../..
cd ../../../../..

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
