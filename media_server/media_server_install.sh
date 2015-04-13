#!/bin/bash -ev

# Install git of course
sudo apt-get install -y git
git clone git@github.com:rranelli/linuxsetup.git

cd linuxsetup

make -f media_server/Makefile
make all -f media_server/Makefile
