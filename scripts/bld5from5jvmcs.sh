#!/bin/sh

java -classpath target5/BEL_system_be_jv.jar:target5/BEL_4_Base_be_jv.jar be.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs
mcs -debug:pdbonly -warn:0 -out:target5/BEL_4_Base_mcs.exe system/cs/be/BELS_Base/*.cs target5/Base/target/cs/be/BEL_4_Base/*.cs
