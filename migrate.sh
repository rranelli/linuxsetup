#!/usr/bin/env bash
set -euo pipefail

for entry in $(mimipass list 2>/dev/null | cut -d' ' -f2-); do
  username=$(mimipass get "${entry}" | grep -oP 'username: \K.*' || true)
  [ -n "${username}" ] && username="Username: ${username}"
  password="Password: $(mimipass get ${entry} | head -n1)"
  url="Url: https://${entry/\/password/}"

  cat <<EOF | lpass add --non-interactive "${entry/\/password/}"
${username}
${password}
${url}
EOF
done
