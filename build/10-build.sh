#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

# Enable nullglob for all glob operations to prevent failures on empty matches
shopt -s nullglob

echo "::group:: Copy Bluefin Config from Common"

# Copy just files from @projectbluefin/common (includes 00-entry.just which imports 60-custom.just)
mkdir -p /usr/share/ublue-os/just/
shopt -s nullglob
cp -af /ctx/oci/common/bluefin/usr/share/ublue-os/just/* /usr/share/ublue-os/just/
shopt -u nullglob

echo "::endgroup::"

echo "::group:: Remove Packages"

# Remove packages
dnf5 remove -y \
    firefox \
    firefox-langpacks \
    gnome-software \
    gnome-extensions-app \
    gnome-shell-extension-background-logo \
    gnome-software-rpm-ostree \
    gnome-terminal-nautilus \
    yubikey-manager

echo "::endgroup::"


echo "::group:: Install Packages"

# Install packages using dnf5 from fedora repos
dnf5 -y install \
    bash-color-prompt \
    bootc \
    fastfetch \
    firewall-config \
    genisoimage \
    git-credential-libsecret \
    git \
    hplip \
    iotop \
    lm_sensors \
    oddjob-mkhomedir \
    openssh-askpass \
    p7zip \
    p7zip-plugins \
    powertop \
    restic \
    tiptop \
    switcheroo-control \
    sysprof \
    waypipe \
    wireguard-tools \
    zsh

# Install Gnome Extensions
dnf5 -y install \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-caffeine \
    gnome-shell-extension-blur-my-shell \
    gnome-backgrounds-extras \
    gnome-tweaks

find /usr/share/gnome-shell/extensions -exec \
  setfattr -n user.component -v gnome-extensions {} +

copr_install_isolated "atim/starship" starship
copr_install_isolated "ublue-os/packages" uupd


# Install tooling needed to develop bootc containers locally
dnf5 -y install \
    qemu-system-x86 \
    osbuild-selinux \
    podman-compose \
    podmansh \
    gvisor-tap-vsock
copr_install_isolated "gmaglione/podman-bootc" podman-bootc

echo "::endgroup::"

echo "::group:: Install Fonts"

# Install fonts
#dnf5 -y install \
#    google-droid-sans-mono-fonts \
#    google-go-mono-fonts \
#    powerline-fonts \
#    ibm-plex-mono-fonts \
#    google-noto-sans-mono-fonts \
#    google-noto-sans-fonts \
#    google-noto-serif-fonts
#copr_install_isolated "che/nerd-fonts" nerd-fonts
#copr_install_isolated "atim/ubuntu-fonts" ubuntu-family-fonts

# Create a dedicated OCI component for fonts
#find /usr/share/fonts -exec \
#  setfattr -n user.component -v fonts {} +

echo "::endgroup::"

echo "::group:: System Configuration"

# Install macadam it is needed by the podman-desktop-bootc extension, but is not packaged by fedora yet.
# Ensure /var/usr/local exists (needed because /usr/local is a symlink to it)
mkdir -p /usr/bin
curl -L -o /usr/bin/macadam https://github.com/crc-org/macadam/releases/download/v0.3.0/macadam-linux-amd64
chmod +x /usr/bin/macadam

# Clamp the timestamp to a fixed date to help chunkah and caching
touch -d "2026-01-01" /usr/bin/macadam

echo "::endgroup::"

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
