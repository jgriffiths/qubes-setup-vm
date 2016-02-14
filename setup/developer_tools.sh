#!/bin/bash

# Install development tools

# C development basics
sudo dnf groupinstall -y "C Development Tools and Libraries"

# Packages for building Qubes and various other projects
sudo dnf install -y git git-email createrepo rpm-build make wget rpmdevtools python-sh python-yaml dialog rpm-sign zlib-devel perl-devel curl-devel expat-devel gettext-devel openssl-devel
