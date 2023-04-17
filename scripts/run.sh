#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"

C_OFF='\033[0m'
C_ERROR='\033[0;31m'
C_WARN='\033[0;33m'

# Check Build image's existence
unset opt
if [[ "$(docker images -q ubuntu-enhanced 2>/dev/null)" == "" ]]; then
    echo -e "${C_WARN}WARNING: ubuntu-enhanced does not exist.${C_OFF}"
    read -p "Build it first? (y/n) [y]: " opt
    opt=${opt:-"y"}
else
    echo -e "${C_WARN}WARNING: ubuntu-enhanced already exist.${C_OFF}"
    read -p "Build it again? (y/n) [n]: " opt
    opt=${opt:-"n"}
fi

if [[ "${opt}" == "y" ]]; then
    read -p "- Ubuntu Version [latest]: " version
    echo -e "INFO: Trying to build ubuntu-enhanced(Ubuntu:${version:-latest})"
    if [[ -n "${version}" ]]; then
        ${SCRIPT_PATH}/build.sh --version $version
    else
        ${SCRIPT_PATH}/build.sh
    fi
elif [[ "$(docker images -q ubuntu-enhanced 2>/dev/null)" == "" ]]; then
    echo -e "${C_ERROR}ERROR: ubuntu-enhanced not exist!${C_OFF}"
    exit 1
else
    echo -e "INFO: Skipping build."
fi

# Get run parameters
echo -e "INFO: Setting up parameters:"
args="-d "

while [ -z "${NAME}" ]; do
    read -p "- Container Name: " NAME
done
args="${args}--name '${NAME}' "

read -p "- Root Password [<RANDOM_VALUE>]: " ROOT_PASSWORD
[ -n "${ROOT_PASSWORD}" ] && args="${args}-e ROOT_PASSWORD='${ROOT_PASSWORD}' "

unset opt
read -p "- SSH Authorized Key (file/str) [str]: " opt
opt=${opt:-"str"}

if [[ "$opt" == "str" ]]; then
    read -p "  + Public Key ['']: " AUTHORIZED_KEY
elif [[ "$opt" == "file" ]]; then
    read -p "  + Public Key Path [~/.ssh/id_rsa.pub]: " AUTHORIZED_KEY_PATH
    AUTHORIZED_KEY_PATH=${AUTHORIZED_KEY_PATH:-"~/.ssh/id_rsa.pub"}
    AUTHORIZED_KEY=$(cat $AUTHORIZED_KEY_PATH 2>/dev/null)
fi

[ -n "${AUTHORIZED_KEY}" ] && args="${args}-e AUTHORIZED_KEY='${AUTHORIZED_KEY}' "

read -p "- Timezone [Asia/Shanghai]: " TZ
[ -n "${TZ}" ] && args="${args}-e TZ='${TZ}' "

read -p "- Exposed Port [2233]: " PORT
args="${args}-p ${PORT:=2233}:22 "

read -p "- Other Parameters (example:'--gpus all') ['']: " OPP
[ -n "${OPP}" ] && args="${args}${OPP} "

echo -e "INFO: Docker args: ${args}"

read -p "Press anything to run."

eval "docker run ${args} ubuntu-enhanced"
