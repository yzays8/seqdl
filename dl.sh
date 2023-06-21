#!/bin/bash

# Set DST_DIR to the destination directory
# Basename must be $1
# Example: readonly DST_DIR="/path/to/destination/directory/"$1""
readonly DST_DIR=""

function usage() {
    cat << EOF
Usage:
    $0 <dir_name> <start_num> <end_num> <file_URL>
Examples:
    $0 dst_dir 001 032 http://example.com/images/001.jpg
    $0 dst_dir 2 8 http://example.com/docs/5.pdf
EOF
}

function cecho() {
    local code="\033["
    case "$1" in
        black  | bk) color="${code}0;30m";;
        red    |  r) color="${code}1;31m";;
        green  |  g) color="${code}1;32m";;
        yellow |  y) color="${code}1;33m";;
        blue   |  b) color="${code}1;34m";;
        purple |  p) color="${code}1;35m";;
        cyan   |  c) color="${code}1;36m";;
        gray   | gr) color="${code}0;37m";;
    esac
    echo -e "${color}$2${code}0m"
}

if [[ $# -ne 4 ]]; then
    usage
    exit 0
fi

if [[ -z $DST_DIR ]]; then
    cecho r "Set the destination directory" >&2
    exit 1
fi

readonly filename_with_ext=$(basename $4)
if [[ ! $filename_with_ext =~ \. ]]; then
    cecho r "The URL must be a file" >&2
    exit 1
fi

readonly filename_without_ext=${filename_with_ext%.*}
readonly ext=${filename_with_ext##*.}

mkdir "$DST_DIR"
if [[ $? -ne 0 ]]; then
    cecho r "Failed to create destination directory: ${DST_DIR}" >&2
    exit 1
fi

mkdir "$1"
if [[ $? -ne 0 ]]; then
    cecho r "Failed to create temp directory: $1" >&2
    exit 1
fi

for i in $(eval echo {$2..$3}); do
    # Change file_name if necessary
    file_name="${i}.$ext"
    url="$(dirname $4)/$file_name"
    cecho b "Currently working on No.${i}: ${url}\n"
    curl $url -f -o "$1"/$i.$ext
    if [[ $? -ne 0 ]]; then
        cecho r "Failed to download: ${url}" >&2
        exit 1
    fi
done

mv "$1"/*.$ext "$DST_DIR"
rmdir "$1"
if [[ $? -ne 0 ]]; then
    cecho r "Failed to remove temp directory: $1" >&2
    exit 1
fi

cecho g "Download completed!"
