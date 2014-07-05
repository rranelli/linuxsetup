#!/bin/bash

# ensure installation of python software properties
sudo apt-get install -y python-software-properties

# add repos
sudo apt-add-repository -y ppa:cassou/emacs
sudo apt-add-repository -y ppa:nviennot/tmate
sudo apt-add-repository -y ppa:git-core/ppa
sudo apt-add-repository -y ppa:lvillani/silversearcher

# update them all
sudo apt-get -qq update
