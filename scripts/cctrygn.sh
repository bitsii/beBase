#!/bin/bash

mkdir -p targetEc
rm -f targetEc/cctrygn.exe

g++ -std=c++11 -o targetEc/cctrygn.exe system/cctry/cctry.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

targetEc/cctrygn.exe
