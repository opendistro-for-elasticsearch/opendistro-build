#!/bin/bash

ARCH=`uname -p | tr '[:upper:]' '[:lower:]'`; echo $ARCH
PLATFORM=`uname -s | tr '[:upper:]' '[:lower:]'`; echo $PLATFORM
DEB_PKGS="curl wget unzip tar jq python python3 git awscli libnss3-dev fonts-liberation libfontconfig1 python-setuptools"
RPM_PKGS="curl wget unzip tar jq python python3 git awscli libnss3.so xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi \
          xorg-x11-utils xorg-x11-fonts-cyrillic xorg-x11-fonts-Type1 xorg-x11-fonts-misc fontconfig freetype python-setuptools"
USER=`whoami`

echo "This script is to installed the required packages for GitHub Runners"

# Install from package managers
if [ "$USER" = "root" ]
then
  apt update -y || (yum repolist && yum check-update)
  apt install -y sudo || yum install -y sudo
fi


sudo apt update -y || (sudo yum repolist && yum check-update)
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
