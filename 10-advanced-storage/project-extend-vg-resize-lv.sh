#!/bin/bash
#
# RHCSA: Extend VG and Resize LV Script
# Purpose: Demonstrate how to add a new disk to a volume group, extend a logical volume
# and grow the filesystem.  Uses a loopback file so it is safe to run on test systems.
#
# This script will:
#   1. Create a 500MiB loopback file and attach it as /dev/loopZ
#   2. Initialise it as a PV and extend an existing VG (defaults to vgdata)
#   3. Extend an existing LV by 100MiB (defaults to lvdata)
#   4. Resize the filesystem automatically
#   5. Report the new size, then clean up on exit
#
set -euo pipefail

VG=${1:-vgdata}
LV=${2:-lvdata}
SIZE_MB=500
EXTEND_SIZE=100M

echo "[+] Creating $SIZE_MB MiB loopback file..."
IMG=$(mktemp /tmp/vgextend-XXXXXX.img)
dd if=/dev/zero of="$IMG" bs=1M count=$SIZE_MB status=none

LOOP=$(losetup --find --show "$IMG")
echo "[+] Attached loopback device: $LOOP"

echo "[+] Initialising $LOOP as a PV"
pvcreate -y "$LOOP"

echo "[+] Extending volume group $VG with $LOOP"
vgextend "$VG" "$LOOP"
vgs "$VG"

echo "[+] Extending logical volume $LV by $EXTEND_SIZE"
lvextend -L +$EXTEND_SIZE -r "/dev/$VG/$LV"
lvs "/dev/$VG/$LV"

echo "[✓] LV and filesystem resized successfully."
echo "[!] Cleaning up loopback device in 5 seconds..."
sleep 5
vgreduce "$VG" "$LOOP"
pvremove -y "$LOOP"
losetup -d "$LOOP"
rm -f "$IMG"
echo "[✓] Clean up complete"