#!/usr/bin/bash

set -eoux pipefail

echo "Adding custom wallpapers..."

mkdir -p /usr/share/backgrounds /usr/share/gnome-background-properties
shopt -s nullglob
cp -r /ctx/oci/wallpapers/* /
shopt -u nullglob

echo "Adding custom wallpapers completed"