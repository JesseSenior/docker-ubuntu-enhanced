#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"

docker build -t ubuntu-enhanced:latest ${SCRIPT_PATH}/..
