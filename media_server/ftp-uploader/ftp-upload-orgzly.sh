#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)

# remove old files
echo -e "\e[0;32mDeleting the random selection directory...\e[0m"
ncftp -u renan -p renanftp -P 5021 motomaxx.rep <<EOF 2>/dev/null || true
  rm -r /storage/emulated/0/Documents/org
  rmdir /storage/emulated/0/Documents/org
  mkdir /storage/emulated/0/Documents/org
EOF
echo -e "\e[0;32mDone...\e[0m"

# upload randomly chosen files
$script_dir/ftp-upload.sh \
    -u renan \
    -p renanftp \
    -P 5021 \
    -h motomaxx.rep \
    -d /storage/emulated/0/Documents/org \
    "$HOME/SpiderOak Hive/org/"*.org 2>/dev/null
