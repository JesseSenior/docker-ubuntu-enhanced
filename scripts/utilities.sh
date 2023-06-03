#!/bin/bash

C_OFF='\033[0m'
C_INFO='\033[0;34m'
C_ERROR='\033[0;31m'
C_WARN='\033[0;33m'

get_version() {
    if !command -v git >/dev/null 2>&1; then
        echo "Unknown (Git not installed)"
        version="Unknown"
        return
    fi

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Unknown (No version information)"
        version="Unknown"
        return
    fi

    version=$(git describe 2>&1) 
    if [ $? -ne 0 ]; then
        echo "Unknown (Failed to get version information)"
        version="Unknown"
        return
    fi
    git diff-index --quiet HEAD -- || version="${version}-changed($(date +%s))"

    echo $version
}

welcome_message() {
    clear
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
    echo "   + $(get_version)                               "
    #echo '=================================================='
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
