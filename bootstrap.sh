#!/bin/bash
set -euo pipefail

sudo apt update -qq || true
sudo apt install -y git python-pip dirmngr aptitude --allow-downgrades
sudo pip install ansible

[ -d linuxsetup ] || (git clone https://github.com/rranelli/linuxsetup.git)
cd linuxsetup

ansible-playbook --ask-become-pass \
                 --ask-vault-pass \
                 -i desktop/ansible/hosts \
                 desktop/ansible/desktop.yml
