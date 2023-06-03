#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"

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
        args="$args --build-arg build_version=$2"
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

eval "docker build -t ubuntu-enhanced:$VERSION ${SCRIPT_PATH}/.. ${args}"
exit $?
