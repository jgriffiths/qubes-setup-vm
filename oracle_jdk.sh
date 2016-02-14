#!/bin/bash

install_vm=$1
java_rpm=$2
template_vm=$(qubes-prefs --get default-template)
net_vm=$(qvm-prefs -g $template_vm netvm)

if [[ $# -ne 2 ]]; then
    echo "usage: oracle_jdk.sh vm_name path_spec"
    exit 1
fi

.  /etc/qubes-setup-vm/setup/dom0_functions.sh

if vm_create $install_vm $template_vm $net_vm; then
    vm_less_logging $install_vm
fi

# Copy JDK to install VM, install and copy it locally
vm_transfer $java_rpm $install_vm:/home/user/jdk.rpm

qvm-run --auto --pass-io $install_vm ' \
    sudo dnf install -y /home/user/jdk.rpm && \
    rm -f /home/user/jdk.rpm && \
    sudo mkdir /rw/usrlocal/java && \
    sudo chmod a+rx /rw/usrlocal/java && \
    sudo cp -a $(readlink /usr/java/latest) /rw/usrlocal/java'

# Set users paths to the local install
qvm-run --auto --pass-io $install_vm " \
    echo 'export JAVA_HOME=/rw/usrlocal/java/\$(ls /rw/usrlocal/java/)/' >>~/.bashrc && \
    echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >>~/.bashrc"
