#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

### Install VS Code from Official Repository
echo "Installing VS Code..."

# Add RPM repository
cat > /etc/yum.repos.d/vs-code.repo << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Install vscode
dnf5 install -y code

# Clean up repo file (required - repos don't work at runtime in bootc images)
rm -f /etc/yum.repos.d/vs-code.repo

echo "VS Code successfully"