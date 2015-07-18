#!/bin/sh

java -classpath target5/Base/target/jv:system/jv abe.BEL_4_Base.BEL_4_Base --buildFile build/buildbuild.txt --deployPath deploy4 --buildPath target4 --emitLang cs
mcs -debug:pdbonly -warn:0 -out:target4/BEL_4_Base_mcs.exe system/cs/abe/BELS_Base/*.cs target4/Base/target/cs/abe/BEL_4_Base/*.cs
