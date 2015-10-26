#!/usr/bin/env bash
set -euo pipefail

# Read options
while getopts :u:d:P:h:p: OPT; do
    case $OPT in
        u|+u)
            ftpuser="$OPTARG"
            ;;
        P|+P)
            ftpport="$OPTARG"
            ;;
        h|+h)
            ftphost="$OPTARG"
            ;;
        p|+p)
            ftppass="$OPTARG"
            ;;
        d|+d)
            upload_dir="$OPTARG"
            ;;
        *)
            echo "usage: ${0##*/} [+-u USER] [+-p PASSWORD] [+-h HOST] [+-P PORT] [+-d DESTINATION] [--] FILES..."
            exit 2
    esac
done
shift $(( OPTIND - 1 ))
OPTIND=1

max_upload_kb=$((${MAX_UPLOAD_SIZE_MB-2000} * 1024))
uploaded=0

# upload all files
for file in "$@"; do
    echo -e "\e[0;32muploading $file ...\e[0m"
    # break out of loop if upload quota has been reached
    filesize=$(du "$file" | awk '{print $1}')
    (( uploaded += $filesize))
    [[ $uploaded -ge $max_upload_kb ]] && break

    ncftpput -R -u $ftpuser -p $ftppass -P $ftpport $ftphost $upload_dir "$file" || true
done
