#!/bin/bash

ARCH=`uname -p | tr '[:upper:]' '[:lower:]'`; echo $ARCH
PLATFORM=`uname -s | tr '[:upper:]' '[:lower:]'`; echo $PLATFORM
DEB_PKGS="curl wget unzip tar jq python python3 git awscli"
RPM_PKGS="curl wget unzip tar jq python python3 git awscli"

echo "This script is to installed the required packages for GitHub Runners"

# Install from package managers
sudo apt update || sudo yum repolist
sudo apt install -y $DEB_PKGS || sudo yum install $RPM_PKGS

# Install from repositories

# yq 4.0.0 version, different usages compares to yq 3.x.x or previous versions
if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]
then
  sudo wget https://github.com/mikefarah/yq/releases/download/4.0.0/yq_${PLATFORM}_amd64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
elif [ "$ARCH" = "x86" ] || [ "$ARCH" = "i386" ]
then
  sudo wget https://github.com/mikefarah/yq/releases/download/4.0.0/yq_${PLATFORM}_386 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
else
  sudo wget https://github.com/mikefarah/yq/releases/download/4.0.0/yq_${PLATFORM}_${ARCH} -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
fi
