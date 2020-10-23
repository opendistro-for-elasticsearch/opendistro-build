#!/bin/bash

# Prepare required packages
if echo $OSTYPE | grep -i linux
then
  if which apt # Debian based linux
  then
    sudo add-apt-repository -y ppa:openjdk-r/ppa
    # Need to update twice as ARM image seems not working correctly sometimes with only one update
    sudo apt update; sudo apt update
    sudo apt install -y curl wget unzip tar jq python python3 git awscli openjdk-8-jdk
    # cypress dependencies
    sudo apt install -y libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb
  elif which yum # RedHat based linux
  then
    # Need to update twice as ARM image seems not working correctly sometimes with only one update
    sudo yum repolist; sudo yum repolist
    sudo yum install -y curl wget unzip tar jq python python3 git awscli java-8-openjdk
    # cypress dependencies
    sudo yum install -y xorg-x11-server-Xvfb gtk2-devel gtk3-devel libnotify-devel GConf2 nss libXScrnSaver alsa-lib
  else
    echo "This script does not support your current os"
    exit 1
  fi
else
  echo "This script only support linux os now"
  exit 1
fi

