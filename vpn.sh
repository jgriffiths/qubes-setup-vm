#!/bin/bash

install_vm=${1:-vpn}
template_vm=$(qubes-prefs --get default-template)
net_vm=$(qvm-prefs -g $template_vm netvm)

.  /etc/qubes-setup-vm/setup/dom0_functions.sh

if vm_create $install_vm $template_vm $net_vm; then
    vm_less_logging $install_vm
    vm_minimum_services $install_vm
fi

# Install vpn scripts into vpn VM
vm_add_to_rc_local $install_vm '. /etc/qubes-setup-vm/vpn/rc.local'

echo "Copy your vpn config to $install_vm:/rw/config/vpn.conf"
echo "Then restart $install_vm"
