#!/bin/bash

set -xeuo pipefail

echo "Setting up services..."

# Enable/disable systemd services
systemctl enable podman.socket

# These should be handled by uupd
#systemctl preset brew-setup.service
#systemctl preset brew-update.timer
#systemctl preset brew-upgrade.timer

systemctl disable rpm-ostreed-automatic.service rpm-ostreed-automatic.timer 
systemctl enable uupd.timer
systemctl mask bootc-fetch-apply-updates.timer bootc-fetch-apply-updates.service

echo "Services setup complete."