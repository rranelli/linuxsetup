#!/usr/bin/env bash
for mod in "${HOME}"/.bashrc.d/*; do
  source "${mod}"
done
