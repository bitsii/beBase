#!/bin/bash

. scripts/bld4env.sh

rm -rf target5/Base/target/cs
rm -rf target5/bin

$BEBLDR --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

cp system/BEX_DN/BEX_DN.csproj target5/Base/target/cs/be
cp system/cs/be/BE* target5/Base/target/cs/be/
cd target5/Base/target/cs/be/

dotnet build
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

mv bin ../../../..
cd ../../../../..

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
