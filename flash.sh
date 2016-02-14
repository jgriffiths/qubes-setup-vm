#!/bin/bash

disp_vm=$(qubes-prefs --get default-template)-dvm

#.  /etc/qubes-setup-vm/setup/dom0_functions.sh

# Start up our dispVM template and fetch the flash rpm to $HOME
# (dispVMs dont get /rw mounted).
qvm-run --auto --pass-io $disp_vm ' \
    touch /home/user/.qubes-dispvm-customized && \
    /etc/qubes-setup-vm/flash/install.sh'

qvm-shutdown --wait $disp_vm

# Create a new dispVM save-file so we pick up the changes
qvm-create-default-dvm --default-template --default-script

echo "sh -c 'echo /etc/qubes-setup-vm/flash/firefox-flash.sh | /usr/lib/qubes/qfile-daemon-dvm qubes.VMShell dom0 DEFAULT red'" >~/firefox-flash.sh
chmod +x ~/firefox-flash.sh

echo run ~/firefox-flash.sh to run firefox with flash in a dispVM.
