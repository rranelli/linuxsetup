#!/usr/bin/env bash
set -euo pipefail

for entry in $(mimipass list | cat); do
  username=$(mimipass get "${entry}" | grep -oP 'username: \K.*')
  password=$(mimipass get "${entry}" | head -n1)

  lpass add --username "${username}" --password "${password}" "${entry}"
done
