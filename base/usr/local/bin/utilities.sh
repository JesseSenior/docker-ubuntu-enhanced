#!/bin/bash

download_url_to_file() {
    if command -v aria2c &>/dev/null; then
        aria2c -s16 -x16 -k1M --check-certificate=false $1 -o $(basename $2) -d $(dirname $2)
    else
        wget $1 -O $2
    fi
    return $?
}

change_mirrors() {
    bash <(curl -sSL https://linuxmirrors.cn/main.sh) \
        --source mirrors.tencent.com \
        --web-protocol http \
        --intranet false \
        --close-firewall false \
        --backup true \
        --updata-software false \
        --clean-cache false \
        --ignore-backup-tips
}

change_mirrors_python() {
    cat <<'EOF' > ~/.condarc
channels:
  - conda-forge
  - nodefaults
show_channel_urls: true
default_channels:
  - https://mirror.nju.edu.cn/anaconda/pkgs/main
  - https://mirror.nju.edu.cn/anaconda/pkgs/r
  - https://mirror.nju.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirror.nju.edu.cn/anaconda/cloud
  bioconda: https://mirror.nju.edu.cn/anaconda/cloud
  pytorch: https://mirror.nju.edu.cn/anaconda/cloud
  fastai: https://mirror.nju.edu.cn/anaconda/cloud
EOF
    pip config set global.index-url https://mirrors.cloud.tencent.com/pypi/simple
}

install_miniconda() {
    download_url_to_file https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh /tmp/InstallMiniconda.sh
    chmod +x /tmp/InstallMiniconda.sh
    bash /tmp/InstallMiniconda.sh -b
    eval "$(/root/miniconda3/bin/conda shell.bash hook)"
    conda init
    pip install pqi
}

install_mambaconda() {
    download_url_to_file "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh" /tmp/InstallMambaforge.sh
    chmod +x /tmp/InstallMambaforge.sh
    bash /tmp/InstallMambaforge.sh -b
    eval "$(/root/mambaforge/bin/conda shell.bash hook)"
    conda init
}

install_essential() {
    apt install -y sudo git vim tmux aria2 build-essential
}

quick_init() {
    change_mirrors && install_essential && install_mambaconda && change_mirrors_python
}
