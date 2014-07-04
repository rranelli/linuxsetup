#!/bin/bash
# Simple script for configuration of dotfiles.

# getting this directory
destdir=`pwd`/dotfiles

# creating the symbolic links
cd $HOME

ln -sf $destdir/.screenrc .
ln -sf $destdir/.bashrc .
ln -sf $destdir/.gitcommittemplate .

cd $destdir
