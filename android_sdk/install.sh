#!/bin/bash

# Pick up install path to android tools
. /home/user/.bashrc

install_package() {
    local n=$(android list sdk | grep "$1" | head -n 1 | sed 's/-.*//g')
    if [[ -n $n ]]; then
        echo "y" | android update sdk -u -t $n
    fi
}

install_package "Platform-tools"
install_package "Build-tools"
install_package "SDK Platform Android"
install_package "Android Support Library"
