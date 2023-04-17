#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"

if [[ "$1" == "--version" && -n "$2" ]]; then
    VERSION="$2"
    docker build -t ubuntu-enhanced:latest ${SCRIPT_PATH}/.. --build-arg version=$VERSION
else
    docker build -t ubuntu-enhanced:latest ${SCRIPT_PATH}/..
fi
