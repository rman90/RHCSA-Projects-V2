#!/bin/bash
#
# RHCSA: LVM Snapshot Demonstration
# Purpose: Create and remove a snapshot for backup purposes.
# Usage: project-lvm-snapshot.sh <vg> <lv> [snapshot_size]
# Defaults: vgdata lvdata 512M
#
# The script will:
#   1. Create a snapshot LV of the given LV
#   2. Mount it at /mnt/lv-snapshot
#   3. Prompt the user to perform backup operations
#   4. Unmount and remove the snapshot

set -euo pipefail

VG=${1:-vgdata}
LV=${2:-lvdata}
SNAPSIZE=${3:-512M}
SNAPNAME=${LV}_snap
MOUNTPOINT=/mnt/lv-snapshot

echo "[+] Creating snapshot $SNAPNAME of /dev/$VG/$LV ($SNAPSIZE)"
lvcreate --size "$SNAPSIZE" --snapshot --name "$SNAPNAME" "/dev/$VG/$LV"

mkdir -p "$MOUNTPOINT"

echo "[+] Mounting snapshot on $MOUNTPOINT"
mount "/dev/$VG/$SNAPNAME" "$MOUNTPOINT"
df -h "$MOUNTPOINT"

echo "[!] Snapshot mounted.  Perform your backup now (e.g. rsync or tar)."
read -rp "Press Enter when done to remove the snapshot..."

echo "[+] Unmounting snapshot"
umount "$MOUNTPOINT"
rmdir "$MOUNTPOINT"

echo "[+] Removing snapshot"
lvremove -y "/dev/$VG/$SNAPNAME"

echo "[✓] Snapshot removed and cleaned up"