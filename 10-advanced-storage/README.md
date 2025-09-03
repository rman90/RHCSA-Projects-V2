# 10 – Advanced Storage

This module builds on the basics of LVM by showing how to extend existing volume groups, resize logical volumes and filesystems, take snapshots and safely remove physical volumes.  These tasks are common in real systems when storage needs grow or when disks must be replaced.

## Extending volume groups

To add more space to a volume group:

1. Prepare a new disk or partition and initialise it as a physical volume:
   ```bash
   sudo pvcreate /dev/sdc
   ```
2. Add it to an existing volume group:
   ```bash
   sudo vgextend vgdata /dev/sdc
   sudo vgs        # verify free space
   ```
3. Create a new logical volume or extend an existing one.  To grow `lvdata` by 10 GiB and resize the filesystem at the same time:
   ```bash
   sudo lvextend -L +10G -r /dev/vgdata/lvdata
   ```
   The `-r` flag tells LVM to resize the filesystem automatically (works for XFS and ext4).  You can also specify percentages using `lvresize -l +50%FREE vgdata/lvdata`.

## Snapshots

LVM snapshots provide point‑in‑time copies of logical volumes.  They are copy‑on‑write, so you only pay for changed blocks.  Typical workflow:

```bash
sudo lvcreate --size 1G --snapshot --name lvdata_snap /dev/vgdata/lvdata
sudo mkdir -p /mnt/snapshot
sudo mount /dev/vgdata/lvdata_snap /mnt/snapshot
# Perform backup (e.g. rsync or tar)
sudo umount /mnt/snapshot
sudo lvremove /dev/vgdata/lvdata_snap
```

Allocate a snapshot large enough to hold expected changes; if it fills up the snapshot becomes invalid.

## Shrinking volumes

Unlike extending, shrinking requires careful planning.  You must unmount the filesystem and reduce it before shrinking the LV:

```bash
sudo umount /dev/vgdata/lvdata
sudo e2fsck -f /dev/vgdata/lvdata             # ext4 only
sudo resize2fs /dev/vgdata/lvdata 20G         # reduce filesystem to 20 GiB
sudo lvreduce -L 20G /dev/vgdata/lvdata       # shrink the LV
sudo mount /dev/vgdata/lvdata /mountpoint
```

Note: XFS cannot be shrunk; copy the data to a new smaller LV instead.

## Removing physical volumes

If a disk must be removed from a VG, you must relocate its extents and then drop it:

```bash
sudo pvmove /dev/sdc /dev/sdb               # move data off /dev/sdc to /dev/sdb
sudo vgreduce vgdata /dev/sdc               # remove PV from the VG
sudo pvremove /dev/sdc                      # wipe PV metadata
```

## Projects

Two scripts accompany this module:

- **project-extend-vg-resize-lv.sh** – demonstrates extending a VG by adding a new loopback disk, growing an LV and filesystem and verifying the change.
- **project-lvm-snapshot.sh** – creates a snapshot of a logical volume, mounts it for backup and cleans up.

Practise using these scripts to familiarise yourself with the commands before working on real disks.