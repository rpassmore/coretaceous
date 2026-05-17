#!/usr/bin/bash

set -eoux pipefail

echo "Adding custom wallpapers..."

mkdir -p /usr/share/backgrounds /usr/share/gnome-background-properties
shopt -s nullglob
cp -af /ctx/oci/wallpapers/* /
shopt -u nullglob

# Create a dedicated OCI component for wallpapers
find /usr/share/gnome-background-properties/ -exec \
  setfattr -n user.component -v dynamic-wallpapers {} +
find /usr/share/backgrounds/Dynamic_Wallpapers/ -exec \
  setfattr -n user.component -v dynamic-wallpapers {} +

echo "Adding custom wallpapers completed"