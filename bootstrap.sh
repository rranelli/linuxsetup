#!/bin/bash
set -euo pipefail

sudo apt update -qq || true
sudo apt install -y git python-pip dirmngr aptitude --allow-downgrades
sudo pip install ansible

if [ -d linuxsetup ]; then
  cd linuxsetup
elif [ -f bootstrap.sh ]; then
  cd .
else
  git clone https://github.com/rranelli/linuxsetup.git
  cd linuxsetup
fi

ansible-playbook --ask-become-pass \
                 --ask-vault-pass \
                 -i desktop/ansible/hosts \
                 desktop/ansible/desktop.yml
