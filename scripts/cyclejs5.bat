node target5/Base/target/js/be/BEL_4_Base/BEL_4_Base.js --buildFile build\buildbuild.txt --deployPath cycle\deploy0 --buildPath cycle\target0 --emitLang js

node cycle/target0/Base/target/js/be/BEL_4_Base/BEL_4_Base.js --buildFile build\buildbuild.txt --deployPath cycle\deploy1 --buildPath cycle\target1 --emitLang js

node cycle/target1/Base/target/js/be/BEL_4_Base/BEL_4_Base.js --buildFile build\buildbuild.txt --deployPath cycle\deploy2 --buildPath cycle\target2 --emitLang js

node cycle/target1/Base/target/js/be/BEL_4_Base/BEL_4_Base.js --buildFile build\extendedEcEc.txt -deployPath=cycle\deployEc -buildPath=cycle\targetEc --emitLang js

node cycle/targetEc/Base/target/js/be/BEL_4_Base/BEL_4_Base.js %*




