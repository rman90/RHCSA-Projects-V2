#!/bin/bash
#
# RHCSA: LVM Creation Demonstration
#
# This script creates a temporary disk image, builds a simple LVM stack on it
# (PV → VG → LV), formats the LV with XFS and mounts it under /mnt/lvm-test.
# Finally it performs cleanup.  Use only on a test system.
#

set -euo pipefail

DISK_IMG="/tmp/lvm-demo.img"
LOOP_DEV=""
MOUNT_POINT="/mnt/lvm-test"

cleanup() {
  echo "[+] Cleaning up..."
  if mountpoint -q "$MOUNT_POINT"; then
    umount "$MOUNT_POINT"
    rm -rf "$MOUNT_POINT"
  fi
  if [[ -n "$LOOP_DEV" && -b "$LOOP_DEV" ]]; then
    losetup -d "$LOOP_DEV"
  fi
  rm -f "$DISK_IMG"
}

trap cleanup EXIT

# 1. Create a 200 MiB image file to emulate a disk
echo "[+] Creating disk image..."
dd if=/dev/zero of="$DISK_IMG" bs=1M count=200 status=none

# 2. Associate a loop device with the image
LOOP_DEV=$(losetup --show -f "$DISK_IMG")
echo "    Loop device: $LOOP_DEV"

# 3. Initialise a PV on the loop device
pvcreate -y "$LOOP_DEV" >/dev/null

# 4. Create a VG
VG_NAME="vgdemo"
vgcreate "$VG_NAME" "$LOOP_DEV" >/dev/null

# 5. Create an LV that uses all free space
LV_NAME="lvdemo"
lvcreate -l 100%FREE -n "$LV_NAME" "$VG_NAME" >/dev/null

# 6. Format the LV with XFS
mkfs.xfs -f "/dev/$VG_NAME/$LV_NAME" >/dev/null

# 7. Mount the LV and create a test file
mkdir -p "$MOUNT_POINT"
mount "/dev/$VG_NAME/$LV_NAME" "$MOUNT_POINT"
echo "Welcome to your new LVM logical volume!" > "$MOUNT_POINT/readme.txt"
ls -l "$MOUNT_POINT"

echo "[✓] LVM setup complete.  The logical volume is mounted at $MOUNT_POINT."
echo "    A cleanup routine will run automatically when the script exits."

read -p "Press Enter to finish and clean up..."
