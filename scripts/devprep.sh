#!/bin/bash

export OSTYPE=`uname`

if [[ "$OSTYPE" == *"MINGW"* ]]; then
  echo "Mswin"
  echo "Windows needs to have some things installed manually"
  echo "first Git (likely done if you ran this script and are reading"
  echo "the output :-)"
  echo "but in case you're reading this some other way"
  echo "https://git-scm.com/download/win"
  echo "then download and install java:"
  echo "https://adoptopenjdk.net/"
  echo "(put it on your path)"
  echo "then download and install mono"
  echo "https://www.mono-project.com/download/stable/#download-win"
  echo "(put it on your path)"
  echo "then download and install nodejs"
  echo "https://nodejs.org/en/download/"
  echo "(put it on your path)"
  echo "then make sure you are in the abelii checked out directory"
  echo "and run ./scripts/boot5jvmswin.sh"
  echo "after it completes run ./scripts/boot5mcsmswin.sh"
fi

if [ "$OSTYPE" == "Linux" ]; then
  echo "Linux"
  sudo apt-get install nodejs
  sudo apt-get install openjdk-11-jdk-headless
  sudo apt-get install mono-complete mono-devel mono-mcs
  sudo apt-get install git
  sudo apt-get install git-gui
  sudo apt-get install clang
  echo "make sure you are in the abelii checked out directory"
  echo "and run ./scripts/boot5jvlinux.sh"
  echo "after it completes run ./scripts/boot5mcslinux.sh"
fi

if [ "$OSTYPE" == "Darwin" ]; then
  echo "Macos"
  echo "Installing required additional system software"
  if ! [ -x "$(command -v brew)" ]; then
    sudo mkdir -p /usr/local
    sudo chown -R $INSUSER /usr/local
    echo "Homebrew, https://brew.sh, is required and will now be installed"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  brew tap homebrew/cask-versions
  brew install openjdk@11
  brew link --force openjdk@11
  brew install mono
  brew install node
  brew install git
  brew install git-gui
  echo "make sure you are in the abelii checked out directory"
  echo "and run ./scripts/boot5jvmacos.sh"
  echo "after it completes run ./scripts/boot5mcsmacos.sh"
fi

echo "then you should be ready to go. test builds:"
echo "./script/extec5mcs.sh"
echo "./script/extec5jv.sh"
echo "./script/cyclejv5.sh"
echo "./script/cyclemcs5.sh"
