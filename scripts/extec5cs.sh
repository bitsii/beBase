#!/bin/bash

. scripts/bld5env.sh

rm -rf targetEc/Base/target/cs
rm -rf targetEc/bin

$BEBLDR --buildFile build/extendedEc.txt --emitLang cs

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

cp system/BEX_DN/BEX_DN.csproj targetEc/Base/target/cs/be
cp system/cs/be/BE* targetEc/Base/target/cs/be/
cd targetEc/Base/target/cs/be/

dotnet build
lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

mv bin ../../../..
cd ../../../../..

./targetEc/bin/Debug/net8.0/BEX_DN

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi
