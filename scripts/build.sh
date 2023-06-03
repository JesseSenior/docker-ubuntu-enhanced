#!/bin/bash
SCRIPT_PATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

VERSION="latest"
args=""

while [[ $# -gt 0 ]]; do
    case $1 in
    --version)
        VERSION="$2"
        args="$args --build-arg version=$2"
        shift # past argument
        shift # past value
        ;;
    --build-version)
        args="$args --build-arg build_version='$2'"
        shift # past argument
        shift # past value
        ;;
    -* | --*)
        echo "Unknown option $1"
        exit 1
        ;;
    *)
        shift # past argument
        ;;
    esac
done

eval "docker build -t ubuntu-enhanced:$VERSION ${args} ${SCRIPT_PATH}/.."
exit $?
