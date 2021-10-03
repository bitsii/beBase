#!/bin/bash

export OSTYPE=`uname`

if [[ "$OSTYPE" == *"MINGW"* ]]; then
  echo "Mswin"
  echo "Windows needs to have some things installed manually"
  echo "download and install java:"
  echo "https://adoptopenjdk.net/"
  echo "(put it on your path)"
  echo "then make sure you are in the brace checked out directory"
  echo "and run ./scripts/boot5jvmswin.sh"
fi

if [ "$OSTYPE" == "Linux" ]; then
  echo "Linux"
  sudo apt-get install openjdk-11-jdk-headless
  echo "make sure you are in the brace checked out directory"
  echo "and run ./scripts/boot5jvlinux.sh"
fi

if [ "$OSTYPE" == "Darwin" ]; then
  echo "Macos"
  brew install openjdk@11
  brew link --force openjdk@11
  echo "make sure you are in the brace checked out directory"
  echo "and run ./scripts/boot5jvmacos.sh"
fi

echo "then you should be ready to go. test builds:"
echo "./script/extec5jv.sh"
echo "./script/cyclejv5.sh"
