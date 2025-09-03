#!/bin/bash
#
# RHCSA: Custom systemd Service Demonstration
#
# This script creates a simple systemd service that writes a message
# to the system journal at boot.  It installs the service, starts it,
# displays its status and logs, and optionally removes it on exit.
#

set -euo pipefail

SERVICE_NAME="hello"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
SCRIPT_PATH="/usr/local/bin/${SERVICE_NAME}.sh"

create_script() {
  cat <<'EOF' > "$SCRIPT_PATH"
#!/bin/bash
logger "[$(basename "$0")] Hello from your custom systemd service at $(date)" || true
EOF
  chmod +x "$SCRIPT_PATH"
  echo "[+] Created script at $SCRIPT_PATH"
}

create_unit() {
  cat <<EOF | tee "$SERVICE_FILE" >/dev/null
[Unit]
Description=Example custom service
After=network.target

[Service]
Type=oneshot
ExecStart=${SCRIPT_PATH}

[Install]
WantedBy=multi-user.target
EOF
  echo "[+] Created unit file at $SERVICE_FILE"
}

start_service() {
  systemctl daemon-reload
  systemctl enable --now "${SERVICE_NAME}.service"
  systemctl status "${SERVICE_NAME}.service"
  echo "[+] Service installed and started."
}

show_logs() {
  echo "[+] Recent log entries for ${SERVICE_NAME}:"
  journalctl -u "${SERVICE_NAME}.service" -n 5 --no-pager
}

cleanup() {
  echo "[*] Cleaning up service..."
  systemctl disable --now "${SERVICE_NAME}.service" || true
  rm -f "$SERVICE_FILE" "$SCRIPT_PATH"
  systemctl daemon-reload
  echo "[✓] Removed service and script."
}

create_script
create_unit
start_service
show_logs

read -p "Press Enter to remove the service and exit..."
cleanup
