#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)

if [ ! $# = 0 ]; then
    $script_dir/ftp-upload.sh \
        -u renan \
        -p renanftp \
        -P 5021 \
        -h motomaxx.rep \
        -d /storage/emulated/0/Music \
        "$@"
    exit 0
fi

# if no files were given, upload a random selection
declare -a files
OLDIFS=$IFS; IFS=$'\n'
albums=(
    $(shuf <(ls -1d $HOME/Music/Renan/*/*))
) # list all 2 levels deep dirs
IFS=$OLDIFS

# remove old files
echo -e "\e[0;32mDeleting the random selection directory...\e[0m"
ncftp -u renan -p renanftp -P 5021 motomaxx.rep <<EOF || true
  rm -r /storage/emulated/0/Music/Random
  rmdir /storage/emulated/0/Music/Random
  mkdir /storage/emulated/0/Music/Random
EOF
echo -e "\e[0;32mDone...\e[0m"

# upload randomly chosen files
$script_dir/ftp-upload.sh \
    -u renan \
    -p renanftp \
    -P 5021 \
    -h motomaxx.rep \
    -d /storage/emulated/0/Music/Random \
    "${albums[@]}"
