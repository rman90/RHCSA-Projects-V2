#!/bin/bash
#
# RHCSA: Journald and rsyslog Demonstration
# Purpose: Show how to enable persistent journald storage, filter journal entries
# and configure rsyslog to capture messages from a custom facility.
#
# Run this script as root on a test system.  It will not make permanent changes
# to your logging configuration but will demonstrate the commands to do so.

set -euo pipefail

echo "[+] Checking journald storage mode..."
STORAGE=$(grep -E '^Storage=' /etc/systemd/journald.conf 2>/dev/null | cut -d= -f2 || echo "auto")
echo "Current Storage setting: $STORAGE"

JOURNAL_DIR=/var/log/journal
if [[ ! -d "$JOURNAL_DIR" ]]; then
  echo "[+] Creating $JOURNAL_DIR for persistent journal"
  mkdir -p "$JOURNAL_DIR"
  chown root:systemd-journal "$JOURNAL_DIR"
  chmod 2755 "$JOURNAL_DIR"
  systemctl restart systemd-journald
  echo "[✓] Journald restarted.  Journals will now persist across reboots."
else
  echo "[INFO] $JOURNAL_DIR already exists; skipping creation"
fi

echo "\n[+] Generating a test message with logger (facility local1, priority info)"
logger -p local1.info "RHCSA troubleshooting test message at $(date)"

echo "[+] Displaying the last 5 journal entries for our user:"
journalctl -n 5

echo "[+] Filtering journal for our test message using _BOOT_ID and facility"
BOOT_ID=$(journalctl --list-boots | head -1 | awk '{print $1}')
journalctl --boot "$BOOT_ID" -p info -t logger | tail -1

echo "\n[+] Demonstrating rsyslog configuration for facility local1"
echo "# Add the following line to /etc/rsyslog.conf or a file in /etc/rsyslog.d/ to log local1 messages" 
echo "local1.*    /var/log/custom-local1.log"

echo "After modifying rsyslog configuration, restart rsyslog with: systemctl restart rsyslog"
echo "You can then tail /var/log/custom-local1.log to see incoming messages."

echo "[✓] Demo complete"