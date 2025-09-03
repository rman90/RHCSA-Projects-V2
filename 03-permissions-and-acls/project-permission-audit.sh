#!/bin/bash
#
# RHCSA: Permission Audit Script
# Purpose: Scan a directory tree for insecure permissions and ownership
# Usage: project-permission-audit.sh [directory] [expected-group]
# Default directory is /shared/projectX, default group is dev.
#
# This script checks for three conditions:
#   1. Files that are world‑writable (others have write permission)
#   2. Directories missing the SGID bit (so new files won’t inherit the group)
#   3. Files not owned by the expected group
#
# It reports each finding and exits with the number of issues found.

DIR=${1:-/shared/projectX}
EXPECTED_GRP=${2:-dev}

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] This script must be run as root." >&2
  exit 1
fi

if [[ ! -d "$DIR" ]]; then
  echo "[ERROR] Directory $DIR does not exist." >&2
  exit 2
fi

echo "[+] Auditing permissions under $DIR (expected group: $EXPECTED_GRP)"

issues=0

# Check for world‑writable files
while IFS= read -r -d $'\0' file; do
  echo "[WARN] World‑writable file: $file"
  ((issues++))
done < <(find "$DIR" -type f -perm -0002 -print0)

# Check for directories missing SGID bit
while IFS= read -r -d $'\0' dir; do
  # Skip the root directory itself when comparing
  if [[ "$dir" != "$DIR" && ! -g "$dir" ]]; then
    echo "[WARN] Directory missing SGID bit: $dir"
    ((issues++))
  fi
done < <(find "$DIR" -type d -print0)

# Check for files not owned by expected group
while IFS= read -r -d $'\0' file; do
  current_grp=$(stat -c %G "$file")
  if [[ "$current_grp" != "$EXPECTED_GRP" ]]; then
    echo "[WARN] File $file is owned by group $current_grp (expected $EXPECTED_GRP)"
    ((issues++))
  fi
done < <(find "$DIR" -type f -print0)

if [[ $issues -eq 0 ]]; then
  echo "[✓] No permission issues found in $DIR"
else
  echo "[!] Audit completed with $issues issue(s) detected"
fi

exit $issues