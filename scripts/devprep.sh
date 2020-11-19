#!/bin/bash

export OSTYPE=`uname`

if [[ "$OSTYPE" == *"MINGW"* ]]; then
  echo "Mswin"
  #hmmm
fi

if [ "$OSTYPE" == "Linux" ]; then
  echo "Linux"
  sudo apt-get install nodejs
  sudo apt-get install openjdk-11-jdk-headless
  sudo apt-get install mono-mcs
fi

if [ "$OSTYPE" == "Darwin" ]; then
  echo "Macos"
  #TODO? install brew
  brew install node
  #TODO brew install jdk and mono
  brew install git-gui
fi
