#!/bin/bash
SCRIPT_PATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

cd $SCRIPT_PATH

source utilities.sh

# Show welcome message
welcome_message

if [[ "$(</proc/sys/kernel/osrelease)" == *WSL2 ]]; then
    pwarn "WSL2 environment detected."
    if ! command -v wslvar &>/dev/null; then
        perr "Command wslvar not found, which is required in WSL2 environment."
        perr "Please install wslu first:"
        pnone "\$ sudo apt install -y wslu"
        exit 1
    fi
fi

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
elif [[ "$(docker inspect -f '{{ index .Config.Labels "container.build-version" }}' ubuntu-enhanced:$version)" != "$build_version" ||
"$(docker inspect -f '{{ index .Config.Labels "container.build-version" }}' ubuntu-enhanced:$version)" == "Unknown" ]]; then
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
    pinfo "Attempt to build ubuntu-enhanced:$version"
    pnone "  - build.sh --version $version --build-version '$build_version'"
    if ! ${SCRIPT_PATH}/build.sh --version $version --build-version "$build_version"; then
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
    if [[ "$(</proc/sys/kernel/osrelease)" == *WSL2 ]]; then
        pwarn "\
You are currently in the WSL2 environment. Please choose whether to resolve the\
 path as the host machine's path or the WSL2 container's path."
        get_choice "    + Path Resolve" "host/wsl" "host" opt
    fi
    get_input "    + Public Key Path" "~/.ssh/id_rsa.pub" AUTHORIZED_KEY_PATH

    # Detect WSL2 Environment
    if [[ "$(</proc/sys/kernel/osrelease)" == *WSL2 && "$opt" == "host" ]]; then
        AUTHORIZED_KEY_PATH=${AUTHORIZED_KEY_PATH/\~/$(wslvar USERPROFILE)}
        AUTHORIZED_KEY_PATH=$(wslpath -a -u ${AUTHORIZED_KEY_PATH})
    fi
    AUTHORIZED_KEY=$(tr -d '\t\r\n' <$AUTHORIZED_KEY_PATH)
fi

[ -n "${AUTHORIZED_KEY}" ] && args="${args}-e AUTHORIZED_KEY='${AUTHORIZED_KEY}' "

get_input "  - Timezone" "Asia/Shanghai" TZ
[ "$TZ" != "Asia/Shanghai" ] && args="${args}-e TZ='${TZ}' "

get_input "  - Exposed Port" "$((RANDOM % 49152 + 16384))" PORT
args="${args}-p 127.0.0.1:${PORT}:22 "

get_input "  - Other Parameters (example:'--gpus all --shm-size=4G')" "''" OPP
[ "${OPP}" != "''" ] && args="${args}${OPP} "

psec "Docker command:"

pnone "\$ docker run ${args} ubuntu-enhanced:$version"

read -p "Press anything to start."

eval "docker run ${args} ubuntu-enhanced:$version"

if [ $? -eq 0 ]; then
    pinfo "Done!"
    psec "Now you can use the following SSH config to access the container with"
    pnone "your public key or root password:"
    pnone "-----"
    pnone "Host ${NAME}"
    pnone "    HostName 127.0.0.1"
    pnone "    Port ${PORT}"
    pnone "    User root"
    pnone "    ProxyJump [user@]hostname[:port] # add this to access container from remote client"
    pnone "-----"
    pnone "Or you can connect via the following ssh command:"
    pnone "\$ ssh -p ${PORT} root@127.0.0.1 -J [user@]hostname[:port]"
    pnone ""
    pnone "To remove the container, run the following command:"
    pnone "\$ docker stop ${NAME} && docker rm ${NAME}"
else
    perr "Failed to create container! Exiting..."
    exit 1
fi
