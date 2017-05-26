#!/bin/sh

java -classpath target5/BEL_system_be_jv.jar:target5/BEX_E_be_jv.jar be.BEX_E.BEX_E --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs
mcs -debug:pdbonly -warn:0 -out:target5/BEX_E_mcs.exe system/cs/be/BELS_Base/*.cs target5/Base/target/cs/be/BEX_E/*.cs
