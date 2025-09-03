# Resetting the Root Password

If you forget the root password, you can reset it by booting into an early shell before the system fully initialises.  The following procedure assumes a GRUB2 boot loader on RHEL and that you have physical console or out‑of‑band access.

1. **Interrupt the boot loader**
   - Reboot the system.
   - At the GRUB menu press `e` on the default kernel entry.
   - Locate the line beginning with `linux` (or `linux16`) and append `init=/bin/bash` to the end.
   - Press `Ctrl+X` to boot with the modified parameters.

2. **Remount the root filesystem**
   You are dropped into a minimal shell with the root filesystem mounted read‑only.  Remount it read/write:

   ```bash
   mount -o remount,rw /
   ```

3. **Change the root password**
   Use the `passwd` command to set a new password:

   ```bash
   passwd
   ```

   Enter and confirm the new password when prompted.

4. **Prepare SELinux relabel (if enabled)**
   Because SELinux is not active in this environment, the context of `/etc/shadow` may be wrong after the change.  Create an autorelabel file so that the next boot relabels all files:

   ```bash
   touch /.autorelabel
   ```

5. **Continue the normal boot process**
   You cannot run `reboot` because systemd is not PID 1.  Instead replace the current shell with systemd:

   ```bash
   exec /usr/lib/systemd/systemd
   ```

   The system will continue booting and perform the SELinux relabel.  After the relabel completes, the machine reboots again and you can log in as root with the new password.