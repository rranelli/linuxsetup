#!/bin/bash
set -euo pipefail

sudo apt update -qq || true
sudo apt install -y git python-pip dirmngr aptitude --allow-downgrades
sudo pip install ansible

mkdir -p ~/code
[ -d ~/code/linuxsetup ] || (cd ~/code && git clone git@github.com:rranelli/linuxsetup.git)
cd ~/code/linuxsetup

ansible-playbook --ask-become-pass \
                 --ask-vault-pass \
                 -i desktop/ansible/hosts \
                 desktop/ansible/desktop.yml
