#!/usr/bin/bash
set -eoux pipefail

echo "Cleaning up dnf caches..."

# Remove any left over dnf caches
dnf5 clean all
rm -rf /var/cache/fontconfig/*
rm -rf /var/cache/dnf /var/cache/libdnf5

# Find all container whiteout markers created by your 'dnf5 remove' step
# and freeze their timestamps to your static base date.
find /usr /var /etc -name ".wh.*" -exec touch -h -d "2026-01-01 00:00:00" {} +

# Vacuum the database if sqlite3 is present to reduce size changes, then clamp
if [ -f /usr/share/rpm/rpmdb.sqlite ]; then
  if command -v sqlite3 &> /dev/null; then
    sqlite3 /usr/share/rpm/rpmdb.sqlite "VACUUM;"
  fi
  touch -d "2026-01-01 00:00:00" /usr/share/rpm/rpmdb.sqlite
fi

echo "Dnf caches cleaning completed"