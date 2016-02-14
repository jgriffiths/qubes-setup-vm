#!/bin/bash

# Remove PackageKit from a template VM

# Actually we can't remove much of PackageKit since everything depends on it.
# In the future we may be able to remove more.

template_vm=${1:-$(qubes-prefs --get default-template)}

qvm-run --auto --pass-io $template_vm 'sudo  dnf remove -y PackageKit-command-not-found'
