#!/bin/bash

# remove abrtd from the template VM

template_vm=${1:-$(qubes-prefs --get default-template)}

qvm-run --auto --pass-io $template_vm /etc/qubes-setup-vm/setup/remove_abrtd.sh
