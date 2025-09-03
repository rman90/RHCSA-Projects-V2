#!/bin/bash
#
# RHCSA: Static IP Configuration Demo
#
# This script uses nmcli to create or modify a connection named "static" on the
# specified interface.  It sets a static IPv4 address, gateway and DNS servers.
# Adjust the variables below before running.
#

set -euo pipefail

# Adjust these variables to match your environment
IFNAME="${IFNAME:-eth0}"
CON_NAME="static"
IP_ADDR="${IP_ADDR:-192.0.2.100/24}"
GATEWAY="${GATEWAY:-192.0.2.1}"
DNS_SERVERS="${DNS_SERVERS:-8.8.8.8 8.8.4.4}"

echo "[+] Configuring static network connection '$CON_NAME' on $IFNAME..."

# Check if connection already exists
if nmcli -g NAME connection show | grep -qx "$CON_NAME"; then
  echo "  • Connection exists; modifying..."
  nmcli connection modify "$CON_NAME" ipv4.addresses "$IP_ADDR" ipv4.gateway "$GATEWAY" ipv4.dns "$DNS_SERVERS" ipv4.method manual connection.autoconnect yes
else
  echo "  • Creating new connection..."
  nmcli connection add con-name "$CON_NAME" ifname "$IFNAME" type ethernet ipv4.addresses "$IP_ADDR" ipv4.gateway "$GATEWAY" ipv4.dns "$DNS_SERVERS" ipv4.method manual
fi

# Bring up the connection
nmcli connection up "$CON_NAME"

echo "[✓] Static connection '$CON_NAME' is active."
nmcli -p device show "$IFNAME" | grep -E 'IP4\.ADDRESS\[|IP4\.DNS|IP4\.GATEWAY'
