#!/bin/bash

change_mirrors() {
    bash <(curl -sSL https://linuxmirrors.cn/main.sh)
}

init_miniconda() {
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh -O /tmp/InstallMiniconda.sh
    chmod +x /tmp/InstallMiniconda.sh
    bash /tmp/InstallMiniconda.sh -b
    eval "$(/root/miniconda3/bin/conda shell.bash hook)"
    conda init
    pip install pqi
}

init_essential() {
    apt install -y sudo git vim tmux build-essential
}
