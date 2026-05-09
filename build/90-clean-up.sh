#!/usr/bin/bash

set -eoux pipefail

echo "Cleaning up dnf caches..."

# Remove any left over dnf caches
dnf5 clean all
rm -rf /var/cache/dnf /var/cache/libdnf5

echo "Dnf caches cleaning completed"