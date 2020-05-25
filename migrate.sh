#!/usr/bin/env bash
set -euo pipefail

lpass ls --color never | grep -oP 'id: \K([^\]]*)' | grep -v 6727720645819537419 | xargs -n1 -I% lpass rm --sync=no %

lpass sync

for entry in $(mimipass list 2>/dev/null | cut -d' ' -f2-); do
  username=$(mimipass get "${entry}" | grep -oP 'username: \K.*' || true)
  [ -n "${username}" ] && username="Username: ${username}"
  password="Password: $(mimipass get ${entry} | head -n1)"

  entry=${entry/\/password/}
  entry=${entry//\//_}
  url="URL: https://${entry}"

  cat <<EOF | lpass add --non-interactive --sync=now "${entry}"
${username}
${password}
${url}
EOF
done
