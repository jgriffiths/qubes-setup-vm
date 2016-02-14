#!/bin/bash

# Remove abrt from a template VM

# Removing all of the abrt- packages from the template is the
# only way to be certain we have disabled this software.

# Get all system abrt services
services=$(sudo systemctl list-unit-files --all | grep "^abrt" | sed 's/ .*//g' | tr '\n' ' ')

# stop/disable/mask are used because systemd sometime fails to
# disable services correctly.
sudo systemctl stop $services
sudo systemctl disable $services
sudo systemctl mask $services

# Remove all abrt-related packages
# libsolv has a bug where it reallocs badly and so this query takes
# >10 minutes under Xen. Hard code the list until this is fixed.
#packages=$(dnf list installed abrt-\* \*-abrt | sed 's/\..*//g' | tr '\n' ' ')
packages="abrt-addon-ccpp abrt-addon-coredump-helper abrt-addon-kerneloops abrt-addon-pstoreoops abrt-addon-python3 abrt-addon-vmcore abrt-addon-xorg abrt-cli abrt-dbus abrt-desktop abrt-gui abrt-gui-libs abrt-java-connector abrt-libs abrt-plugin-bodhi abrt-python3 abrt-retrace-client abrt-tui abrt"

sudo dnf remove -y $packages
