#!/bin/bash

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

mkdir $DST_DIR
if [[ $? -eq 0 ]]; then
    for i in $(eval echo {$2..$3}); do
        url=$(dirname $4)/$i.$ext
        cecho b "Currently working on No.${i}: ${url}\n"
        curl $url --output $i.$ext
        mv $i.$ext $DST_DIR
    done
else
    cecho r "Failed to create directory: ${DST_DIR}" >&2
    exit 1
fi

if [[ $? -eq 0 ]]; then
    cecho g "Download completed!"
else
    cecho r "Download (partly) failed!" >&2
    exit 1
fi
