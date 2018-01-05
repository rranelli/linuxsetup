#!/bin/bash -ev
sudo apt install -y git ansible dirmngr aptitude --allow-downgrades

if [ ! -f ~/.ssh/id_rsa.pub ]; then
    cat /dev/zero | ssh-keygen -q -N ""

    echo "Add this ssh key to your github account!"
    cat ~/.ssh/id_rsa.pub
    echo "Press [Enter] to continue..." && read
fi

mkdir -p ~/code
[ -d ~/code/linuxsetup ] || git clone git@github.com:rranelli/linuxsetup.git
cd ~/code/linuxsetup

ansible-playbook --ask-become-pass \
                 --ask-vault-pass \
                 -i desktop/ansible/hosts \
                 desktop/ansible/desktop.yml
