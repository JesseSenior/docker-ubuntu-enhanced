#!/bin/bash

C_OFF='\033[0m'
C_INFO='\033[0;34m'
C_ERROR='\033[0;31m'
C_WARN='\033[0;33m'

get_build_version() {
    declare -n ret=$1
    ret="Unknown"

    if !command -v git >/dev/null 2>&1; then
        ret="Unknown (Git not installed)"
        return
    fi

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        ret="Unknown (No git repository)"
        return
    fi

    ret=$(git describe --tags 2>&1)
    if [ $? -ne 0 ]; then
        ret="Unknown (Failed to get version information)"
        return
    fi
    [ -z "$(git status --porcelain=v1 2>/dev/null)" ] || ret="${ret}-changed($(date +%s))"
}

welcome_message() {
    clear
    get_build_version build_version
    echo '=================================================='
    echo '       ██████╗       ██╗   ██╗      ███████╗      '
    echo '       ██╔══██╗      ██║   ██║      ██╔════╝      '
    echo '       ██║  ██║█████╗██║   ██║█████╗█████╗        '
    echo '       ██║  ██║╚════╝██║   ██║╚════╝██╔══╝        '
    echo '       ██████╔╝      ╚██████╔╝      ███████╗      '
    echo '       ╚═════╝        ╚═════╝       ╚══════╝      '
    echo '=================================================='
    echo '  ##########  Docker Ubuntu Enhanced  ##########  '
    echo '=================================================='
    echo ' - Author: Jesse Senior                           '
    echo ' - License: MIT License                           '
    echo ' - Current Version:                               '
    echo "   + $build_version                               "
    [[ $build_version = Unknown* ]] && build_version='Unknown'
}

pnone() {
    echo -e "$1"
}

psec() {
    echo -n
    echo '=================================================='
    echo -n
    echo -e "$1"
}

pinfo() {
    echo -e "${C_INFO}INFO: $1${C_OFF}"
}

pwarn() {
    echo -e "${C_WARN}WARNING: $1${C_OFF}"
}

perr() {
    echo -e "${C_ERROR}ERROR: $1${C_OFF}"
}

# get_input <prompt> [default value] <return variable>
get_input() {
    if [ $# -eq 2 ]; then
        declare -n ret=$2
        unset ret

        while [ -z "$ret" ]; do
            read -r -p "$1: " ret
        done
    else
        declare -n ret=$3
        unset ret

        read -r -p "$1 [$2]: " ret
        ret=${ret:-"$2"}
    fi
}

# get_input <prompt> <choice/array/string> [default value] <return variable>
get_choice() {
    local choice_array
    IFS='/' read -r -a choice_array <<<"$2"
    if [ $# -eq 3 ]; then
        declare -n ret=$3
        unset ret

        while [[ ! "/$2/" =~ "/$ret/" ]]; do
            read -r -p "$1 ($2): " ret
        done
    else
        declare -n ret=$4
        unset ret

        while [[ ! "/$2/" =~ "/$ret/" ]]; do
            read -r -p "$1 ($2) [$3]: " ret
            ret=${ret:-"$3"}
        done
    fi
}

# get_yn <prompt> [default value]
get_yn() {
    if [ $# -eq 1 ]; then
        while [[ ! "yYnN" =~ "$ret" || -z "$ret" ]]; do
            read -r -p "$1 (y/n): " ret
        done
    else
        while [[ ! "yYnN" =~ "$ret" || -z "$ret" ]]; do
            if [[ "yY" =~ "$2" ]]; then
                read -r -p "$1 (Y/n): " ret
                ret=${ret:-"y"}
            else
                read -r -p "$1 (y/N): " ret
                ret=${ret:-"n"}
            fi
        done
    fi
    if [[ "yY" =~ "$ret" ]]; then
        return 1
    else
        return 0
    fi
}
