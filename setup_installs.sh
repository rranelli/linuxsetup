#!/bin/bash
# DO NOT RUN AS SUDO!
# sudo will be asked when it's needed
# ------------------------------------------------------------------------------

#adding repos
sudo apt-get install -y python-software-properties

sudo apt-add-repository -y ppa:cassou/emacs
sudo apt-add-repository -y ppa:git-core/ppa

sudo apt-get -qq update

# install git
sudo apt-get install -y git

# install curl
sudo apt-get install -y curl

# Install Heroku toolbelt
# https://toolbelt.heroku.com/debian
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sudo sh

# setup ssh
sudo apt-get install -y ssh openssh-server

# Install emacs24
sudo apt-get install -y emacs24 emacs24-el emacs24-common-non-dfsg

# Install screen
sudo apt-get install -y screen

# Install bash completion
sudo apt-get install -y bash-completion

#set completion-ignore-case on
sudo echo 'set completion-ignore-case on' >> /etc/inputrc
