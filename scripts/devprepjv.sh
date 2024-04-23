#!/bin/bash

export OSTYPE=`uname`

if [[ "$OSTYPE" == *"MINGW"* ]]; then
  echo "Mswin"
  echo "Windows needs to have some things installed manually"
  echo "first Git (likely done if you ran this script and are reading"
  echo "the output :-)"
  echo "but in case you're reading this some other way"
  echo "https://git-scm.com/download/win"
  echo "download and install java:"
  echo "https://adoptopenjdk.net/"
  echo "(put it on your path)"
  echo "then make sure you are in the beBase checked out directory"
  echo "(you likely are right now)"
  echo "and run ./scripts/boot5jvmswin.sh"
fi

if [ "$OSTYPE" == "Linux" ]; then
  echo "Linux"
  sudo apt-get install openjdk-11-jdk-headless
  sudo apt-get install git
  sudo apt-get install git-gui
  echo "make sure you are in the beBase checked out directory"
  echo "(you likely are right now)"
  echo "and run ./scripts/boot5jvlinux.sh"
fi

if [ "$OSTYPE" == "Darwin" ]; then
  echo "Macos"
  echo "Installing required additional system software"
  if ! [ -x "$(command -v brew)" ]; then
    sudo mkdir -p /usr/local
    sudo chown -R $USER /usr/local
    echo "Homebrew, https://brew.sh, is required and will now be installed"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew tap homebrew/cask-versions
  brew install openjdk@11
  brew link --force openjdk@11
  brew install git
  brew install git-gui
  echo "make sure you are in the beBase checked out directory"
  echo "(you likely are right now)"
  echo "and run ./scripts/boot5jvmacos.sh"
fi

echo "then you should be ready to go. test builds:"
echo "./script/extec5jv.sh"
echo "./script/cycle5jv.sh"
