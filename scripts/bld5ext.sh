#!/bin/bash

export CLASSPATH=../beBase/target5/*
BEBLDR="java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base"
#BEBLDR="java be.BEL_Base"

#BEBLDR="time ./target5/BEX_E.exe"

#BEBLDR="time node target5/Base/target/js/be/BEL_Base.js"

export CC=g++
export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"
#export CPFLAGS="-DBEDCC_PT=1 -pthread -std=c++11 -Wfatal-errors -ggdb"

#export CC=clang++
#export CPFLAGS="-ferror-limit=1 -std=c++11"

#export BECCS="ccSs"
#export BECCMACS="system/cc/be/BEH_SGC.hpp"

export BECCS="ccHs"
export BECCMACS="../beBase/system/cc/be/BEH_SGCBEQ.hpp"
