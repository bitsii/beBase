#!/bin/sh

mono target4/BEL_4_Base_mcs.exe --buildFile build/buildbuild.txt --deployPath deploy5 --buildPath target5 --emitLang cs
javac system/jv/abe/BELS_Base/*.java target4/Base/target/jv/abe/BEL_4_Base/*.java
