# 14 – Troubleshooting Skills

Effective administrators know how to diagnose and resolve problems quickly.  This module consolidates several troubleshooting areas covered throughout the course: SELinux, systemd journals vs rsyslog, rescue/emergency modes and log rotation.

## SELinux states and contexts

SELinux can operate in three states:

- **Enforcing** – Denies access based on policy and logs denials.
- **Permissive** – Does not enforce policy but logs what would have been denied.  Useful for troubleshooting.
- **Disabled** – No SELinux enforcement or logging (only for debugging kernels).

Check with `getenforce` or `sestatus`.  Temporarily change the mode with `setenforce 0` (permissive) or `setenforce 1` (enforcing).  Persistent state is set in `/etc/selinux/config`.

File and process contexts are triplets of `user_u:role_r:type_t`.  The **type** dictates access.  View contexts with `ls -Z` (files) and `ps -Z` (processes).  Manage file contexts with `semanage fcontext` and apply them with `restorecon`.  Adjust booleans with `getsebool` and `setsebool`.

## Journald vs rsyslog

systemd‑journald collects kernel messages, early boot logs and service output.  Journals are volatile by default; create `/var/log/journal` (owned by root:systemd-journal, mode 2755) to persist logs across reboots.  Tune `/etc/systemd/journald.conf` to limit size and set rotation.  Use `journalctl` for powerful filtering by unit, priority, PID, UID and time.

rsyslog reads traditional syslog messages and writes them to `/var/log/*`.  It is fully configurable via `/etc/rsyslog.conf` and drop‑ins under `/etc/rsyslog.d`.  Each rule has a facility, priority and destination.  Example: log Apache errors using facility `local1` into a custom file.  Use `logger` to generate test messages.

## Rescue and emergency targets

When the system fails to boot normally, you can append kernel arguments at the GRUB prompt:

- `systemd.unit=emergency.target` – A minimal environment with only the root filesystem mounted read‑only.  Requires the root password.
- `systemd.unit=rescue.target` – Similar to single‑user mode; more services are started and network may be available.  Also requires the root password.
- `rd.break` – Drop into the initramfs before the root filesystem mounts.  Great for fixing `fstab` or resetting root passwords.

Use `systemctl isolate rescue.target` from a running system to enter rescue mode without rebooting.  Exit by typing `exit` or rebooting.

## Log rotation

Logs can fill disks if not rotated.  The `logrotate` utility (driven by a systemd timer) rotates files under `/var/log` based on size, age or time.  Configuration is in `/etc/logrotate.conf` and `/etc/logrotate.d/*.conf`.  You can force a rotation with `logrotate -f` and test with `logrotate -d`.  See `man logrotate` for options.

## Projects

- **journalctl-rsyslog-examples.sh** – Contains commands demonstrating persistent journals, filtering journal entries, configuring rsyslog to capture a custom facility and generating test messages.