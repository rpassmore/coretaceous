#!/usr/bin/bash

set -eoux pipefail

echo "Cleaning up dnf caches..."

# Remove any left over dnf caches
dnf5 clean all
rm -rf /var/cache/fontconfig/*
rm -rf /var/cache/dnf /var/cache/libdnf5

if [ -f /usr/share/rpm/rpmdb.sqlite ]; then
  # Clamp the timestamp to a fixed historical date so the cache never breaks
  touch -d "2026-01-01 00:00:00" /usr/share/rpm/rpmdb.sqlite
fi

echo "Dnf caches cleaning completed"