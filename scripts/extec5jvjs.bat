
java -classpath target5/BEL_system_be_jv.jar;target5/BEL_4_Base_be_jv.jar be.BEL_4_Base.BEL_4_Base --buildFile build\extendedEc.txt --emitLang js

node targetEc/Base/target/js/be/BEL_4_Base/BEL_4_Base.js %*
