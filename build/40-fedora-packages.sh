#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

# Setup repos for packages from Bluefin DX that we want
#dnf5 -y copr enable ganto/umoci
#dnf5 -y copr enable ublue-os/staging
#dnf5 -y copr enable ublue-os/packages
#dnf5 -y copr enable karmab/kcli
#dnf5 -y copr enable hikariknight/looking-glass-kvmfr

# this installs a package from fedora repos
dnf5 -y install \
    bash-color-prompt \
    bootc \
    fastfetch \
    firewall-config \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-caffeine \
    gnome-shell-extension-search-light \
    gnome-shell-extension-blur-my-shell \
    gnome-backgrounds-extras \
    gnome-tweaks \
    hplip \
    lm_sensors \
    oddjob-mkhomedir \
    openssh-askpass \
    powertop \
    uupd \
    google-noto-fonts-all \
    restic \
    switcheroo-control \
    waypipe \
    wireguard-tools \
    zsh

copr_install_isolated "atim/starship" starship
copr_install_isolated "che/nerd-fonts" nerd-fonts

# Add packages from that are included in the bluefin dx version
dnf5 -y install \
    genisoimage \
    git-credential-libsecret \
    git \
    google-droid-sans-mono-fonts \
    google-go-mono-fonts \
    ibm-plex-mono-fonts \
    iotop \
    p7zip \
    p7zip-plugins \
    powerline-fonts \
    sysprof \
    tiptop

copr_install_isolated "atim/ubuntu-fonts" ubuntu-family-fonts

# Install tooling needed to develop bootc containers locally
copr_install_isolated "gmaglione/podman-bootc" podman-bootc

dnf5 -y install \
    osbuild-selinux \
    podman-compose \
    podmansh \
    gvisor-tap-vsock
    #podman-machine

    #docker-buildx-plugin \
    #docker-ce \
    #docker-ce-cli \
    #docker-compose-plugin \
    #docker-model-plugin \
    #rocm-hip \
    #rocm-opencl \
    #rocm-smi \

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

# Install macadam it is needed by the podman-desktop-bootc extension, but is not packaged by fedora yet.
mkdir -p /usr/local/bin
curl -L -o /usr/local/bin/macadam https://github.com/crc-org/macadam/releases/download/v0.2.0/macadam-linux-amd64
chmod +x /usr/local/bin/macadam

# Install dynamic wallpapers
curl -s "https://raw.githubusercontent.com/rpassmore/Linux_Dynamic_Wallpapers/main/Easy_Install.sh" | bash
