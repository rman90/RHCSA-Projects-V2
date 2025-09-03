#!/bin/bash
#
# RHCSA: File Permissions and ACL Demonstration Script
# Purpose: Demonstrate use of standard permissions and ACLs on a shared project directory
# Run this script as root or with sudo

# Create required groups and users
echo "[+] Setting up environment..."
groupadd dev 2>/dev/null || true
groupadd qa 2>/dev/null || true

useradd -m -G dev devuser 2>/dev/null || true
useradd -m -G qa qauser 2>/dev/null || true

# Create shared directory
mkdir -p /shared/projectX
touch /shared/projectX/app.log

# Assign ownership and basic permissions
chown devuser:dev /shared/projectX/app.log
chmod 640 /shared/projectX/app.log

# Apply ACLs for fine-grained access
echo "[+] Applying ACLs..."
setfacl -m u:qauser:rw /shared/projectX/app.log
setfacl -m g:qa:r-- /shared/projectX/app.log

# Display results
echo "[+] Verifying file settings..."
ls -l /shared/projectX/app.log
echo
getfacl /shared/projectX/app.log

echo "[✓] ACL configuration complete."
