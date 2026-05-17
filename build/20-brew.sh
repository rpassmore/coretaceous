#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail


echo "::group:: Copy Custom Files"

# Copy Brewfiles to standard location
cp -af /ctx/oci/brew/* /
mkdir -p /usr/share/ublue-os/homebrew/
cp -af /ctx/custom/brew/*.Brewfile /usr/share/ublue-os/homebrew/

# Consolidate Just Files
find /ctx/custom/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just

# Copy Flatpak preinstall files
mkdir -p /etc/flatpak/preinstall.d/
cp -af /ctx/custom/flatpaks/*.preinstall /etc/flatpak/preinstall.d/

echo "::endgroup::"