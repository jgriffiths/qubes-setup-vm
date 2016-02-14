#!/bin/bash

# Install flash from our home directory and run it
sudo dnf -y -q install /home/user/flash-plugin.rpm
/etc/qubes-setup-vm/flash/install.sh
exec /bin/firefox $*
