#!/bin/bash

# First time init for dom0.
# Safe to run multiple times if needed.

template_vm=$(qubes-prefs --get default-template)
git_branch=${1:-master}

# qvm-ls really should have query and output options
count=$(qvm-ls | grep Running | egrep -v "dom0} |sys-net} |sys-firewall} |$template_vm} " | wc -l)

if (( $count > 0 )); then
    echo "error: you must shutdown all running appVMs before running this script:"
    qvm-ls | grep Running
    exit 1
fi

restart_sys_vms() {
    qvm-shutdown --wait $template_vm
    qvm-shutdown --wait sys-firewall
    qvm-shutdown --wait sys-net
    qvm-start sys-firewall
}

cd ~

#
# Update dom0
#
sudo qubes-dom0-update

#
# Update template vm
#
qvm-run --auto --pass-io $template_vm "sudo dnf update -y"
qvm-run --auto --pass-io $template_vm "sudo dnf install -y git"
restart_sys_vms

#
# install qubes-setup-vm to /etc/qubes-setup/vm in dom0 and template vm
#
qvm-run --auto --pass-io sys-firewall \
    "git clone https://github.com/jgriffiths/qubes-setup-vm && \
     cd qubes-setup-vm && git checkout $git_branch && cd .. && \
     rm -rf qubes-setup-vm/.git && \
     tar cf qsv.tar qubes-setup-vm && \
     rm -rf qubes-setup-vm"

qvm-run --pass-io sys-firewall 'cat /home/user/qsv.tar' >~/qsv.tar

cat ~/qsv.tar | qvm-run --auto --pass-io $template_vm 'cat >/home/user/qsv.tar'

qvm-run --pass-io $template_vm \
    'cd /etc && \
     sudo rm -rf qubes-setup-vm && \
     sudo tar xf /home/user/qsv.tar &&
     rm /home/user/qsv.tar'

cd /etc
sudo rm -rf qubes-setup-vm
sudo tar xf ~/qsv.tar
rm ~/qsv.tar
cd ~

#
# Reboot system VMs to pick up updates
#
restart_sys_vms

#
# Install command completion
#
if [[ ! -d ~/.qubes ]]; then
    mkdir ~/.qubes
    qvm-run --pass-io sys-firewall \
        'wget -q https://raw.githubusercontent.com/jgriffiths/qubes-completion/master/qvm_completion.sh -O -' \
         >~/.qubes/qvm_completion.sh
    echo '. ~/.qubes/qvm_completion.sh' >>~/.bashrc
fi
