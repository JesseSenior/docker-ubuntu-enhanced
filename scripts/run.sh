#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"

C_OFF='\033[0m'
C_INFO='\033[0;34m'
C_ERROR='\033[0;31m'
C_WARN='\033[0;33m'

# Specify Ubuntu Version
echo -e "${C_INFO}INFO: Preparing ubuntu-enhanced image:${C_OFF}"
read -p "  - Ubuntu Version [latest]: " version

# Ensure Build image's existence
unset opt
version=${version:-"latest"}
if [[ "$(docker images -q ubuntu-enhanced:$version 2>/dev/null)" == "" ]]; then
    echo -e "${C_WARN}WARNING: ubuntu-enhanced:$version does not exist.${C_OFF}"
    read -p "Build it first? (y/n) [y]: " opt
    if [[ "${opt:="y"}" != "y" ]]; then
        echo -e "${C_ERROR}ERROR: ubuntu-enhanced:$version not exist!${C_OFF}"
        exit 1
    fi
else
    echo -e "${C_WARN}WARNING: ubuntu-enhanced:$version already exist.${C_OFF}"
    read -p "Build it again? (y/n) [n]: " opt
    opt=${opt:-"n"}
fi

if [[ "${opt}" == "y" ]]; then
    echo -e "${C_INFO}INFO: Trying to build ubuntu-enhanced:$version${C_OFF}"
    ${SCRIPT_PATH}/build.sh --version $version
else
    echo -e "${C_WARN}WARNING: Skipping build.${C_OFF}"
fi

# Get run parameters
echo -e "${C_INFO}INFO: Setting up parameters:${C_OFF}"
args="-d "

while [ -z "${NAME}" ]; do
    read -p "  - Container Name: " NAME
done
args="${args}--name '${NAME}' "

read -p "  - Root Password [<RANDOM_VALUE>]: " ROOT_PASSWORD
[ -n "${ROOT_PASSWORD}" ] && args="${args}-e ROOT_PASSWORD='${ROOT_PASSWORD}' "

unset opt
read -p "  - SSH Authorized Key (file/str) [str]: " opt
opt=${opt:-"str"}

if [[ "$opt" == "str" ]]; then
    read -p "    + Public Key ['']: " AUTHORIZED_KEY
elif [[ "$opt" == "file" ]]; then
    read -p "    + Public Key Path [~/.ssh/id_rsa.pub]: " AUTHORIZED_KEY_PATH
    AUTHORIZED_KEY_PATH=${AUTHORIZED_KEY_PATH:-"~/.ssh/id_rsa.pub"}
    AUTHORIZED_KEY=$(cat $AUTHORIZED_KEY_PATH 2>/dev/null)
fi

[ -n "${AUTHORIZED_KEY}" ] && args="${args}-e AUTHORIZED_KEY='${AUTHORIZED_KEY}' "

read -p "  - Timezone [Asia/Shanghai]: " TZ
[ -n "${TZ}" ] && args="${args}-e TZ='${TZ}' "

read -p "  - Exposed Port [2233]: " PORT
args="${args}-p ${PORT:=2233}:22 "

read -p "  - Other Parameters (example:'--gpus all') ['']: " OPP
[ -n "${OPP}" ] && args="${args}${OPP} "

echo -e "${C_INFO}INFO: Docker command:${C_OFF}"
echo -e "  - docker run ${args} ubuntu-enhanced:$version"

read -p "Press anything to run."

eval "docker run ${args} ubuntu-enhanced:$version"
