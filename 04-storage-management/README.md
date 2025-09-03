# 04 – Storage Management

This module covers managing disks and filesystems on RHEL, including basic partitioning, formatting, mounting, using labels/UUIDs and an introduction to Logical Volume Management (LVM).

## Disks, partitions and filesystems

- **Listing storage** – Use `lsblk -o NAME,SIZE,TYPE,MOUNTPOINT` to view disks, partitions and logical volumes.  `blkid` shows UUIDs and filesystem types.  `fdisk -l` or `parted -l` provide detailed partition tables.
- **Partitioning** – On BIOS/MBR systems use `fdisk`, on GPT/UEFI systems use `gdisk` or `parted`.  Typical flow: create a new partition, set its type (e.g. `8e00` for LVM on GPT) and write the changes.
- **Formatting** – Create a filesystem on a partition or logical volume with `mkfs` (e.g. `mkfs.xfs /dev/sdb1`).  XFS is the default on RHEL 9; you can also use `mkfs.ext4` for ext4 or others like `mkfs.vfat`.
- **Mounting** – Use `mount /dev/sdb1 /mnt/data` to mount temporarily.  To mount automatically at boot, edit `/etc/fstab`:
  ```
  UUID=<uuid>  /mnt/data  xfs  defaults  0 0
  ```
  Always use either the UUID or a label; device names like `/dev/sdb1` can change across reboots.
- **swap** – Create swap partitions with `mkswap /dev/sdc2` and add to `/etc/fstab`, or use a swap file with `dd if=/dev/zero of=/swapfile bs=1M count=1024` then `chmod 600 /swapfile`, `mkswap /swapfile` and `swapon /swapfile`.

## Introduction to LVM

Logical Volume Management allows you to group disks or partitions into pools of storage and create flexible logical volumes.  The workflow has three layers:

1. **Physical Volume (PV)** – A disk or partition initialised with `pvcreate /dev/sdb1`.
2. **Volume Group (VG)** – A pool of one or more PVs created with `vgcreate vgdata /dev/sdb1`.
3. **Logical Volume (LV)** – A slice of the VG created with `lvcreate -n lvdata -L 10G vgdata`.

Once the LV is created, format it (e.g. `mkfs.xfs /dev/vgdata/lvdata`) and mount it.  LVM makes it easy to resize volumes and add new physical disks later.

Common LVM commands:

| Command | Description |
|-------:|------------|
| `pvcreate /dev/sdX` | Initialise a disk or partition as a physical volume. |
| `pvs`, `pvdisplay` | Summarise or show detailed information about PVs. |
| `vgcreate vgname PV…` | Create a new volume group from PVs.  Use `-s` to set physical extent size (default 4 MiB). |
| `vgs`, `vgdisplay` | Show information about VGs. |
| `lvcreate -n lvname -L size vgname` | Create a logical volume of the given size.  Use `-l` to specify extents or percentages (e.g. `-l 100%FREE`). |
| `lvs`, `lvdisplay` | Show LV summaries or details. |
| `lvextend`/`lvresize` | Increase LV size (use `-r` to resize the filesystem at the same time). |
| `vgreduce`, `pvremove` | Remove PVs from a VG and return them to unused space. |

## Projects

The script `project-create-lvm.sh` demonstrates creating an LVM hierarchy in a safe test environment.  It:

1. Creates a loopback file to simulate a disk.
2. Uses `losetup` to attach it as `/dev/loopX`.
3. Initialises a PV, creates a VG and LV.
4. Formats and mounts the LV.
5. Cleans up afterwards.

> **Important:** Only practise these steps on test systems or loopback devices, not on production disks.
