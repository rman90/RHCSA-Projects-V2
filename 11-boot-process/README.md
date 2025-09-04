# 📁 11 – Boot Process and System Recovery

This module explains the stages of a Linux boot, common failure points and techniques to recover when things go wrong.  You will learn how to interrupt GRUB, modify kernel arguments, enter rescue or emergency modes and reset the root password.

## Boot sequence overview

1. **POST (Power‑On Self‑Test)** – Firmware initialises hardware and selects a boot device.
2. **Boot loader** – GRUB2 reads its configuration from `/boot/grub2/grub.cfg` or `/boot/efi/EFI/redhat/grub.cfg`, displays a menu and loads the kernel and initramfs into memory.
3. **Kernel and initramfs** – The kernel decompresses and mounts the initramfs, which contains drivers and early userspace programs such as `dracut`.  It loads necessary modules, mounts the real root filesystem on `/sysroot` and then executes `/sbin/init`.
4. **systemd** – PID 1 switches to the real root and processes unit files.  It starts the `initrd.target` units first, then the default target (`multi-user.target` or `graphical.target`).  Login prompts appear once `getty@.service` or a display manager is running.

## Troubleshooting techniques

- **Edit kernel parameters in GRUB** – At the GRUB menu, press `e` on a menu entry.  You can append parameters such as `rd.break` (stop in initramfs), `systemd.unit=rescue.target` or `init=/bin/bash`.  Press `Ctrl+X` to boot with the edits.
- **Reset forgotten root password** – Use `init=/bin/bash` to drop into a root shell early.  Remount the root filesystem read/write (`mount -o remount,rw /`), use `passwd` to set a new root password, create the file `/.autorelabel` and then execute `exec /usr/lib/systemd/systemd` to continue the boot.
- **Emergency and rescue targets** – Append `systemd.unit=emergency.target` to get a minimal shell requiring the root password, or `systemd.unit=rescue.target` for a slightly fuller environment.  Both are useful for fixing `fstab` errors or running `fsck`.
- **Dracut and initramfs** – Regenerate the initramfs if drivers are missing or corrupted with `dracut -f`.  Custom dracut configs live in `/etc/dracut.conf.d`.
- **Rescue image** – Boot from installation media, choose *Troubleshooting → Rescue a Red Hat Enterprise Linux system*, mount your system under `/mnt/sysimage` and chroot into it (`chroot /mnt/sysimage`) to repair GRUB or fix `fstab`.

## Projects

- **reset-root-password.md** – A step‑by‑step guide to resetting the root password by booting with `init=/bin/bash`.
- **grub-troubleshooting.md** – Common GRUB problems and how to regenerate configuration or reinstall the boot loader.