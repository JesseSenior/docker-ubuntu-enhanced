#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"

source utilities.sh

# Show welcome message
welcome_message

### 1. Specify Ubuntu Version ###
psec "Preparing ubuntu-enhanced image:"
get_input "  - Ubuntu Version" "latest" version

### 2. Build ubuntu-enhanced ###
if [[ "$(docker images -q ubuntu-enhanced:$version 2>/dev/null)" == "" ]]; then
    pwarn "ubuntu-enhanced:$version does not exist."
    get_yn "Build it first?" "y"
    opt=$?
    if [[ "$opt" == "0" ]]; then
        perr "ubuntu-enhanced:$version is required but not exist!"
        exit 1
    fi
elif [[ "$(docker inspect -f '{{ index .Config.Labels "container.build-version" }}' ubuntu-enhanced:$version)" != "$version" || "$(docker inspect -f '{{ index .Config.Labels "container.build-version" }}' ubuntu-enhanced:$version)" == "Unknown" ]]; then
    pwarn "ubuntu-enhanced:$version exist but may be outdated."
    get_yn "Build it again?" "y"
    opt=$?
else
    pinfo "ubuntu-enhanced:$version already exist."
    get_yn "Build it again?" "n"
    opt=$?
fi

# Build image
if [[ "$opt" == "1" ]]; then
    pinfo "Clean up the dangling images."
    docker image prune -a -f --filter "label=container.parent-name=ubuntu-enhanced" --filter "label=container.version=$version"
    pinfo "Attempt to build ubuntu-enhanced:$version"=
    if ! ${SCRIPT_PATH}/build.sh --version $version; then
        perr "Failed to build ubuntu-enhanced:$version!"
        exit 1
    fi
    pinfo "Build ubuntu-enhanced:$version succeeded."
else
    pwarn "Build has been skipped."
fi

### 3. Set up container's parameters ###
psec "Setting up parameters:"
args="-d "

get_input "  - Container Name" NAME
args="${args}--name '${NAME}' "

get_input "  - Root Password" "<RANDOM_VALUE>" ROOT_PASSWORD
[ "$ROOT_PASSWORD" != "<RANDOM_VALUE>" ] && args="${args}-e ROOT_PASSWORD='${ROOT_PASSWORD}' "

get_choice "  - SSH Authorized Key" "file/str" "str" opt

if [[ "$opt" == "str" ]]; then
    get_input "    + Public Key" "''" AUTHORIZED_KEY
    [ "$AUTHORIZED_KEY" == "''" ] && unset AUTHORIZED_KEY
elif [[ "$opt" == "file" ]]; then
    [[ "$(</proc/sys/kernel/osrelease)" == *WSL2 ]] && pwarn "WSL2 environment detected, path will be converted."
    get_input "    + Public Key Path" "~/.ssh/id_rsa.pub" AUTHORIZED_KEY_PATH

    # Detect WSL2 Environment
    if [[ "$(</proc/sys/kernel/osrelease)" == *WSL2 ]]; then
        AUTHORIZED_KEY_PATH=${AUTHORIZED_KEY_PATH/\~/"$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)"}
        AUTHORIZED_KEY_PATH=$(wslpath -a -u ${AUTHORIZED_KEY_PATH})
    fi
    AUTHORIZED_KEY=$(cat ${AUTHORIZED_KEY_PATH})
fi

[ -n "${AUTHORIZED_KEY}" ] && args="${args}-e AUTHORIZED_KEY='${AUTHORIZED_KEY}' "

get_input "  - Timezone" "Asia/Shanghai" TZ
[ "$TZ" != "Asia/Shanghai" ] && args="${args}-e TZ='${TZ}' "

get_input "  - Exposed Port" "2233" PORT
args="${args}-p ${PORT}:22 "

get_input "  - Other Parameters (example:'--gpus all')" "''" OPP
[ "${OPP}" != "''" ] && args="${args}${OPP} "

psec "Docker command:"

pnone "  - docker run ${args} ubuntu-enhanced:$version"

read -p "Press anything to start."

eval "docker run ${args} ubuntu-enhanced:$version"
