#!/bin/bash

# Install some useful apps that we trust in the template VM
# These apps may run in their own appvm but don't need to be
# isolated there while installing or hived into an app VMs
# private storage, unlike apps like Skype that we completely
# distrust.

# Enable the rpmfusion repos (but not debug or source repos)
sudo sed -i '0,/enabled/{s/enabled=.*/enabled=1/}' /etc/yum.repos.d/rpmfusion-free.repo
sudo sed -i '0,/enabled/{s/enabled=.*/enabled=1/}' /etc/yum.repos.d/rpmfusion-free-updates.repo

sudo dnf install -y vlc qbittorrent picard
