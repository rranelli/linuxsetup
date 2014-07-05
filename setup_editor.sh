#!/bin/bash
# Install Heroku toolbelt || https://toolbelt.heroku.com/debian
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sudo sh

# Installing emacs with X
sudo apt-get install -y emacs24 emacs24-el emacs24-common-non-dfsg

sudo apt-get install -y silversearcher-ag
sudo apt-get install -y tmate
sudo apt-get install -y tmux
