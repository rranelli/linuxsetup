#!/usr/bin/env python
import os

username = 'renan'

homedir  = '/home/{0}'.format(username)
dirname  = os.getcwd() + '/dotfiles'

for file in os.listdir(dirname):
    head = '{0}/{1}'.format(dirname, file)
    tail = "{0}/{1}".format(homedir, file)

    if os.path.islink(tail): os.unlink(tail)
    if os.path.isfile(tail): os.remove(tail)
    os.symlink(head, tail)
