#!/bin/bash

# Fetch the flash plugin for later installation (unless already installed)

if ! sudo dnf list installed flash-plugin >/dev/null 2>&1; then

    if [[ ! -f /home/user/flash-plugin.rpm ]]; then
        # Enable adobe repo, download and store the flash rpm
        sudo sed -i 's/enabled=.*/enabled=1/' /etc/yum.repos.d/adobe-linux-x86_64.repo
        sudo dnf --downloadonly -y -q install flash-plugin
        cp /var/cache/dnf/adobe-linux-x86_64*/packages/flash-plugin*.rpm /home/user/flash-plugin.rpm
    fi
fi
