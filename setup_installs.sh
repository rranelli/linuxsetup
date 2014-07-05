#!/bin/bash

sudo apt-get install -y ssh openssh-server
sudo apt-get install -y git
sudo apt-get install -y curl
sudo apt-get install -y bash-completion

#set completion-ignore-case on
sudo echo 'set completion-ignore-case on' >> /etc/inputrc
