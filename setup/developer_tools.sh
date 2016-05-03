#!/bin/bash

# Install development tools

# C development basics
sudo dnf groupinstall -y "C Development Tools and Libraries"

# Packages for building Qubes and various other projects
sudo dnf install -y git git-email createrepo rpm-build make wget rpmdevtools python-devel python-sh python-yaml python-tools dialog rpm-sign zlib-devel perl-devel curl-devel expat-devel gettext-devel openssl-devel python3-devel clang clang-analyzer lcov
