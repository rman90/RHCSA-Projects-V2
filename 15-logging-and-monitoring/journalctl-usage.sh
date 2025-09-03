#!/bin/bash
#
# RHCSA: Journalctl Usage Demonstration
# Purpose: Show various filtering options when using journalctl.

echo "[+] Messages from the current boot:"
journalctl -b -n 5

echo "\n[+] SSH service log (if installed):"
journalctl -u sshd.service -n 5 || echo "sshd.service logs not found"

echo "\n[+] Messages with priority error and above (err, crit, alert, emerg):"
journalctl -p err..emerg -n 5

echo "\n[+] Messages from the last hour:"
journalctl --since "-1 hour" -n 5

echo "\n[+] Kernel ring buffer (dmesg equivalent):"
journalctl -k -n 5

echo "\n[✓] Journalctl usage demo complete"