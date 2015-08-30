
CYC0=`date +%s`

mono --debug target5/BEL_4_Base_mcs.exe --buildFile build/buildbuild.txt --deployPath cycle/deploy0 --buildPath cycle/target0 --emitLang cs

CYC1=`date +%s`

mcs -debug:pdbonly -warn:0 -out:cycle/target0/BEL_4_Base_mcs.exe system/cs/be/BELS_Base/*.cs cycle/target0/Base/target/cs/be/BEL_4_Base/*.cs

CYC2=`date +%s`

mono --debug cycle/target0/BEL_4_Base_mcs.exe --buildFile build/buildbuild.txt --deployPath cycle/deploy1 --buildPath cycle/target1 --emitLang cs

CYC3=`date +%s`

mcs -debug:pdbonly -warn:0 -out:cycle/target1/BEL_4_Base_mcs.exe system/cs/be/BELS_Base/*.cs cycle/target1/Base/target/cs/be/BEL_4_Base/*.cs

CYC4=`date +%s`

mono --debug cycle/target1/BEL_4_Base_mcs.exe --buildFile build/buildbuild.txt --deployPath cycle/deploy2 --buildPath cycle/target2 --emitLang cs

CYC5=`date +%s`

mcs -debug:pdbonly -warn:0 -out:cycle/target2/BEL_4_Base_mcs.exe system/cs/be/BELS_Base/*.cs cycle/target2/Base/target/cs/be/BEL_4_Base/*.cs

CYC6=`date +%s`

mono --debug cycle/target2/BEL_4_Base_mcs.exe --buildFile build/extendedEcEc.txt -deployPath=cycle/deployEc -buildPath=cycle/targetEc --emitLang cs

CYC7=`date +%s`

mcs -debug:pdbonly -warn:0 -out:cycle/targetEc/BEL_4_Base_mcs.exe system/cs/be/BELS_Base/*.cs cycle/targetEc/Base/target/cs/be/BEL_4_Base/*.cs

CYC8=`date +%s`

mono --debug cycle/targetEc/BEL_4_Base_mcs.exe $*

CYC9=`date +%s`

expr \( $CYC1 - $CYC0 \) + \( $CYC3 - $CYC2 \) + \( $CYC5 - $CYC4 \) + \( $CYC7 - $CYC6 \) + \( $CYC9 - $CYC8 \)