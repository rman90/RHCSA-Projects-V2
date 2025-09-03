#!/bin/bash
#
# RHCSA: Create Local DNF Repository
# Purpose: Turn a directory of RPMs into a DNF/YUM repository and write a repo file.
# Usage: create-local-repo.sh <path-to-rpms> [reponame]
# Example: sudo ./create-local-repo.sh /srv/rpms local-baseos

set -euo pipefail

RPMDIR=${1:-/srv/rpms}
REPONAME=${2:-localrepo}
REPOPATH=/srv/repos/$REPONAME

if [[ $EUID -ne 0 ]]; then
  echo "Run as root." >&2
  exit 1
fi

if [[ ! -d "$RPMDIR" ]]; then
  echo "Directory $RPMDIR does not exist or is not a directory." >&2
  exit 2
fi

echo "[+] Creating repository in $REPOPATH"
mkdir -p "$REPOPATH"
cp "$RPMDIR"/*.rpm "$REPOPATH" 2>/dev/null || true

if ! command -v createrepo_c >/dev/null 2>&1; then
  echo "[INFO] Installing createrepo_c..."
  dnf -y install createrepo_c
fi

createrepo_c "$REPOPATH"

REPOFILE=/etc/yum.repos.d/$REPONAME.repo
BASEURL="file://$REPOPATH"

echo "[+] Writing repo file to $REPOFILE"
cat > "$REPOFILE" <<EOF
[$REPONAME]
name=Local Repo $REPONAME
baseurl=$BASEURL
enabled=1
gpgcheck=0
EOF

echo "[✓] Local repository created.  Use 'dnf repolist' to verify."