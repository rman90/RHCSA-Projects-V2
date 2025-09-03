#!/bin/bash
#
# RHCSA: User and Group Management Script
#
# This script demonstrates how to create users in bulk, assign them to groups
# and enforce password policies.  It should be executed with root privileges.
#
# Usage:
#   sudo ./project-add-users.sh user1 user2 user3
#
# If no user names are supplied on the command line the script will create a
# few example accounts.

set -euo pipefail

# Ensure we are running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Default groups to create (idempotent)
DEFAULT_GROUPS=(engineering marketing)

# Create groups if they do not already exist
echo "[+] Creating groups if missing..."
for grp in "${DEFAULT_GROUPS[@]}"; do
  if ! getent group "$grp" >/dev/null; then
    groupadd "$grp"
    echo "  • Created group: $grp"
  else
    echo "  • Group exists: $grp"
  fi
done

# Determine users to create – use arguments if provided, otherwise examples
if [[ $# -gt 0 ]]; then
  USERS=("$@")
else
  USERS=(alice bob charlie dave)
fi

DEFAULT_PASS="Welcome123!"

echo "[+] Creating users..."
for user in "${USERS[@]}"; do
  if id "$user" &>/dev/null; then
    echo "  • User $user already exists – skipping"
    continue
  fi

  # Assign to engineering if name starts with a–c, otherwise marketing
  if [[ $user =~ ^[a-cA-C] ]]; then
    primary_group="engineering"
  else
    primary_group="marketing"
  fi

  useradd -m -s /bin/bash -g "$primary_group" "$user"
  echo "$user:$DEFAULT_PASS" | chpasswd
  # Force password change on first login
  chage -d 0 "$user"

  echo "  • Created $user (primary group: $primary_group)"
done

echo "[+] Summary of new accounts:"
for user in "${USERS[@]}"; do
  if id "$user" &>/dev/null; then
    id "$user"
    chage -l "$user" | grep "Password"
    echo
  fi
done

echo "[✓] User and group setup complete.  Remember to customise groups and shells as needed."
