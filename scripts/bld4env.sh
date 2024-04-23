#!/bin/bash

export CLASSPATH=target4/*
BEBLDR="java -XX:-UsePerfData -XX:TieredStopAtLevel=1 -XX:+UseSerialGC be.BEL_Base"

#BEBLDR="java be.BEL_Base"

#BEBLDR="time node target4/Base/target/js/be/BEL_Base.js"

export CC=g++
export CPFLAGS="-std=c++11 -Wfatal-errors -ggdb"

export BECCS="ccHs"
export BECCMACS="system/cc/be/BEH_SGCBEQ.hpp"
