#!/bin/bash

install_vm=$1
android_sdk_tarball=$2
install_dir=${3:-/home/user/AndroidSDK}
template_vm=$(qubes-prefs --get default-template)
net_vm=$(qvm-prefs -g $template_vm netvm)

if [[ $# -lt 2 ]]; then
    echo "usage: android_sdk.sh vm_name path_spec [install_dir]"
    exit 1
fi

.  /etc/qubes-setup-vm/setup/dom0_functions.sh

# Install deps in template VM
qvm-run --auto --pass-io $template_vm 'sudo dnf install -y \
    glibc.i686 glibc-devel.i686 libstdc++.i686 zlib-devel.i686 \
    ncurses-devel.i686 libX11-devel.i686 libXrender.i686 libXrandr.i686'

# Shutdown template VM so new VMs get freshly updated packages
qvm-shutdown --wait $template_vm

if vm_create $install_vm $template_vm $net_vm; then
    vm_less_logging $install_vm
else
    qvm-shutdown --wait $install_vm
fi

# Copy SDK to VM and install it
vm_transfer $android_sdk_tarball $install_vm:/home/user/android.tgz

qvm-run --auto --pass-io $install_vm " \
    tar xf android.tgz && \
    rm -f android.tgz && \
    mv android-sdk-linux $install_dir && \
    echo 'export PATH=\$PATH:$install_dir/tools:$install_dir/platform-tools' >>~/.bashrc"

# Install android packages for development
qvm-run --auto --pass-io $install_vm '/etc/qubes-setup-vm/android_sdk/install.sh'
