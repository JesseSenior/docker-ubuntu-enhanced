#!/bin/bash -e

# If ROOT_PASSWORD is not defined, it is set to a random value of length 12.
if [ -z "${ROOT_PASSWORD}" ]; then
    export ROOT_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12)
    echo "export ROOT_PASSWORD='${ROOT_PASSWORD}'" >>/root/.bashrc
fi

# If TZ is not defined, it is set to Asia/Shanghai
[ -z "${TZ}" ] && export TZ=Asia/Shanghai

ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
echo "root:${ROOT_PASSWORD}" | chpasswd

if [ -n "${AUTHORIZED_KEY}" ] && ! grep -q "${AUTHORIZED_KEY}" "/root/.ssh/authorized_keys"; then
    echo "${AUTHORIZED_KEY}" >>/root/.ssh/authorized_keys
fi

exec "$@"
