#!/bin/bash

export OSTYPE=`uname`

if [[ "$OSTYPE" == *"MINGW"* ]]; then
  echo "Mswin"
  echo "Windows needs to have some things installed manually"
  echo "download and install nodejs"
  echo "https://nodejs.org/en/download/"
  echo "(put it on your path)"
fi

if [ "$OSTYPE" == "Linux" ]; then
  echo "Linux"
  sudo apt-get install nodejs
fi

if [ "$OSTYPE" == "Darwin" ]; then
  echo "Macos"
  brew install node
fi

echo "then you should be ready to go - test builds:"
echo "./script/extec5js.sh"
