#!/bin/bash

mkdir -p targetEc
rm -f targetEc/TryIt

swiftc -o targetEc/TryIt system/swtry/*.swift

targetEc/TryIt
