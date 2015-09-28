del /s /q targetEc\Base\target\jv

java -classpath target5/BEL_system_be_jv.jar;target5/BEL_4_Base_be_jv.jar be.BEL_4_Base.BEL_4_Base --buildFile build\extendedEc.txt --emitLang jv
javac system\jv\be\BELS_Base\*.java targetEc\Base\target\jv\be\BEL_4_Base\*.java
java -classpath targetEc\Base\target\jv;system\jv be.BEL_4_Base.BEL_4_Base %*
