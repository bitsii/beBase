#!/bin/bash

mkdir -p targetEc
rm -f targetEc/cctrycl.exe

clang++ -std=c++11 -o targetEc/cctrycl.exe system/cctry/cctry.cpp

lae=$?;if [[ $lae -ne 0 ]]; then exit $lae; fi

targetEc/cctrycl.exe
