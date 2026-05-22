#!/usr/bin/bash
set -eoux pipefail

echo "::group:: Advanced Cache Cleaning"

# Clear out package manager trash and transient font caches
dnf5 clean all
rm -rf /var/cache/fontconfig/*
rm -rf /var/cache/dnf /var/cache/libdnf5

# PURGE OR CLAMP MIN GW CROSS-LOCALES (Saves ~40-50MB of drift)
# If these packages are present, freeze their localization directories 
# so chunkah sees zero delta day-to-day.
if [ -d /usr/x86_64-w64-mingw32 ]; then
  find /usr/x86_64-w64-mingw32 -type d -exec touch -h -d "2026-01-01 00:00:00" {} +
fi

echo "::endgroup::"

echo "::group:: Runtime purge "

# Fix 'var-tmpfiles': Wipe all persistent tracking states written by dnf/rpm
rm -rf /var/lib/dnf
rm -rf /var/lib/iscsi
# clear up libvirt files, they will be recreated at runtime by the systemd tmpfiles.d
rm -rf /var/lib/libvirt

# Fix 'nonempty-run-tmp': Erase dynamic state indicators captured in /run and /tmp
# These are generated at build time by system calls and security engines
rm -rf /run/dnf
rm -rf /run/gluster
rm -rf /run/selinux-policy
rm -rf /tmp/* /tmp/.* 2>/dev/null || true

echo "::endgroup::"

echo "::group:: Freezing System Configuration Timestamps"

# Freeze Core RPM DB
if [ -f /usr/share/rpm/rpmdb.sqlite ]; then
  touch -d "2026-01-01 00:00:00" /usr/share/rpm/rpmdb.sqlite
fi

# 4. Freeze SELinux Entirely
if [ -d /etc/selinux ]; then
  find /etc/selinux -exec touch -h -d "2026-01-01 00:00:00" {} +
fi

# 5. Freeze GDM, Firewalld, and general /etc configuration drift
# This forces the metadata hashes under /etc to perfectly align across builds
find /etc/gdm /etc/firewalld /etc/grub.d -exec touch -h -d "2026-01-01 00:00:00" {} + 2>/dev/null || true

# 6. Catch any lingering root locale directories touched during package transactions
find /usr/share/locale -type d -exec touch -h -d "2026-01-01 00:00:00" {} +

echo "::endgroup::"
echo "Image stabilization completed successfully!"
