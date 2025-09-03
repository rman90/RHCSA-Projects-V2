# 21 – Boot Troubleshooting

This final module gathers advanced techniques for fixing boot failures.  Use it alongside Module 11 on the boot process.  Here you learn to diagnose missing devices, incorrect `fstab` entries and broken initramfs images.

## Identifying boot phase failures

When a system fails to boot, note where it stops:

1. **Before GRUB menu** – Hardware or BIOS/UEFI issue; check firmware settings and boot order.
2. **GRUB prompt** – Corrupted or missing boot loader; reinstall GRUB (see Module 11).  Use `grub2-install` and regenerate `grub.cfg`.
3. **Dracut/initramfs stage** – Root filesystem not found; common causes are missing drivers or wrong root UUID.  Use the `rd.break` kernel parameter to stop in the initramfs, then inspect `/proc/cmdline`, `ls /sysroot/dev` and `blkid` to identify the correct device.  If necessary, rebuild the initramfs with `dracut -f`.
4. **Switching root** – Messages like `Give root password for maintenance` indicate issues mounting filesystems from `/etc/fstab`.  Use emergency mode or `rd.break` to edit `/sysroot/etc/fstab` and comment out problematic entries; use `systemctl daemon-reload` and reboot.

## Fixing `fstab` errors

Wrong UUIDs or absent devices can drop you into emergency mode.  Steps:

1. Enter the root password at the prompt.
2. Remount root read/write: `mount -o remount,rw /`.
3. View the journal: `journalctl -xb` to see the failing unit.  Identify which mount failed.
4. Edit `/etc/fstab` and comment or correct the offending line.  Use `blkid` to find current UUIDs.
5. Remount all or reboot: `mount -a` to test; if successful, reboot.

## Using rescue media

If the system cannot reach GRUB at all, boot from RHEL installation media and choose **Troubleshooting → Rescue a Red Hat Enterprise Linux system**.  The rescue environment will mount your system under `/mnt/sysimage` and offer a shell.  Use `chroot /mnt/sysimage` to operate as if the system were running.  From there you can edit files, reinstall GRUB or run `fsck`.

## Repairing initramfs and drivers

Sometimes the initramfs lacks drivers for new hardware.  After chrooting into your system or booting into rescue mode, regenerate the initramfs:

```bash
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
```

If you have installed new kernel packages, make sure `/boot` has enough space.  Remove old kernels with `dnf remove kernel-oldversion` or adjust `/boot` partitions.

## Projects

- Simulate an `fstab` failure by mounting a nonexistent UUID and practise entering emergency mode to fix it.
- Copy your `/boot/initramfs-$(uname -r).img` to a safe location, remove it and rebuild with `dracut -f`.  Compare sizes.
- Use a rescue ISO to chroot into your system and reinstall GRUB to another disk.