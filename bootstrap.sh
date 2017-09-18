#!/bin/bash -ev
echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' \
  | sudo tee /etc/apt/sources.list.d/ansible-trusty.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt-get update -qq
sudo apt-get install -y git ansible

if [ ! -f ~/.ssh/id_rsa.pub ]; then
    cat /dev/zero | ssh-keygen -q -N ""

    echo "Add this ssh key to your github account!"
    cat ~/.ssh/id_rsa.pub
    echo "Press [Enter] to continue..." && read
fi

mkdir -p ~/code/linuxsetup && cd ~/code/linuxsetup
git clone git@github.com:rranelli/linuxsetup.git .

ansible-playbook --ask-become-pass \
                 --ask-vault-pass \
                 -i desktop/ansible/hosts \
                 desktop/ansible/desktop.yml
