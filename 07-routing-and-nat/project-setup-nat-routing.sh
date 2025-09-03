#!/bin/bash
#
# RHCSA: Routing and NAT Demonstration
#
# This script enables IP forwarding and configures firewalld to masquerade
# outbound traffic from an internal interface to an external interface.  It also
# assigns interfaces to firewalld zones.  Adjust variables before running.
#

set -euo pipefail

# Define your internal and external interfaces here
INTERNAL_IF="${INTERNAL_IF:-eth0}"
EXTERNAL_IF="${EXTERNAL_IF:-eth1}"

echo "[+] Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1 >/dev/null
if ! grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf; then
  echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
fi

echo "[+] Configuring firewalld zones..."
firewall-cmd --permanent --new-zone=internal || true
firewall-cmd --permanent --new-zone=external || true
firewall-cmd --permanent --zone=internal --add-interface="$INTERNAL_IF"
firewall-cmd --permanent --zone=external --add-interface="$EXTERNAL_IF"

echo "[+] Enabling masquerading on external zone..."
firewall-cmd --permanent --zone=external --add-masquerade

firewall-cmd --reload

echo "[✓] NAT configuration applied."
echo "Internal interface: $INTERNAL_IF → zone 'internal'"
echo "External interface: $EXTERNAL_IF → zone 'external' (masquerading enabled)"
