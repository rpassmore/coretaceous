#!/usr/bin/bash

set -eoux pipefail

echo "Adding custom wallpapers..."

mkdir -p /usr/share/ublue-os/just/
shopt -s nullglob
cp -r /ctx/oci/wallpapers/* /usr/share/
shopt -u nullglob

echo "Adding custom wallpapers completed"