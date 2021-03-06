#!/bin/bash

ARCH=`uname -p | tr '[:upper:]' '[:lower:]'`; echo $ARCH
PLATFORM=`uname -s | tr '[:upper:]' '[:lower:]'`; echo $PLATFORM
DEB_PKGS="sudo curl wget unzip tar jq python python3 git awscli"
RPM_PKGS="sudo curl wget unzip tar jq python python3 git awscli"

echo "This script is to installed the required packages for GitHub Runners"

# Install from package managers
sudo apt update || sudo yum repolist
sudo apt install -y $DEB_PKGS || sudo yum install -y $RPM_PKGS

# Install from repositories

# yq 4.0.0+ version, different usages compares to yq 3.x.x or previous versions
YQ_VERSION=4.4.1

if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]
then
  sudo wget -nv https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${PLATFORM}_amd64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
elif [ "$ARCH" = "x86" ] || [ "$ARCH" = "i386" ]
then
  sudo wget -nv https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${PLATFORM}_386 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]
then
  sudo wget -nv https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${PLATFORM}_arm64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
elif [ "$ARCH" = "aarch" ] || [ "$ARCH" = "arm" ]
then
  sudo wget -nv https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${PLATFORM}_arm -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
else
  sudo wget -nv https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${PLATFORM}_${ARCH} -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
fi
