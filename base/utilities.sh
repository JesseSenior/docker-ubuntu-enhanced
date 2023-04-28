#!/bin/bash

change_mirrors() {
    bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh)
}

init_miniconda() {
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh -O /tmp/InstallMiniconda.sh
    chmod +x /tmp/InstallMiniconda.sh
    bash /tmp/InstallMiniconda.sh
}

init_essentials() {
    apt install -y sudo git vim tmux
}