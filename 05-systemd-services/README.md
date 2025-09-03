# 05 – Systemd Services and Journals

RHEL uses the `systemd` init system to manage everything from services and sockets to mount points and timers.  This module explains how to control services, work with unit files and troubleshoot using the journal.

## Units and targets

- **Units** describe resources that systemd manages.  Common types include `service`, `socket`, `target`, `mount`, `timer`, `path` and `device`.
- **Services** (`.service` units) start and stop daemons.  They define the binary to execute, dependencies and actions to take on reload or restart.
- **Targets** group units to describe a system state (similar to SysV runlevels).  For example, `multi-user.target` is a non‑graphical multi‑user system, and `graphical.target` builds on it with a display manager.

View loaded units with:

```bash
systemctl list-units --type=service
systemctl list-unit-files --type=service
systemctl get-default       # Show current default target
```

Change the default target with:

```bash
sudo systemctl set-default multi-user.target
```

## Controlling services

- **Start/stop/restart:** `systemctl start sshd.service`, `systemctl stop firewalld.service`.
- **Enable/disable:** `systemctl enable httpd.service` (start at boot), `systemctl disable cockpit.socket`.
- **Check status:** `systemctl status chronyd.service` shows whether it is running and displays the last few log entries.
- **Reload:** `systemctl reload nginx.service` sends a `SIGHUP` to the process so it rereads its configuration.

Units are stored in `/usr/lib/systemd/system` (distribution defaults).  You can override or extend them in `/etc/systemd/system`; systemd merges these at runtime.

## The systemd journal

systemd collects log messages from the kernel, early boot, syslog and daemons via `systemd-journald`.  Use `journalctl` to explore logs:

| Command | Description |
|-------:|-------------|
| `journalctl -b` | Show messages from the current boot. |
| `journalctl -u sshd.service` | Show logs for a specific unit. |
| `journalctl -p err` | Show only error (or higher) priority messages. |
| `journalctl -f` | Follow the log in real time. |
| `journalctl --list-boots` | List persistent boots (if the journal is configured to persist). |

By default journals are stored in `/run/log/journal` and vanish on reboot.  To make them persistent, create `/var/log/journal` and set proper ownership (`chown root:systemd-journal` and `chmod 2755`).  Restart `systemd-journald` to activate.

## Creating custom services

Custom services allow you to run your own scripts at boot.  The project script `project-create-service.sh` shows how to:

1. Write a simple script under `/usr/local/bin` (e.g. a greeting).
2. Write a unit file `/etc/systemd/system/hello.service` specifying the script, dependencies and restart behaviour.
3. Enable and start the service.
4. Verify logs with `journalctl -u hello.service`.

Cleaning up is as simple as disabling the unit and removing the files.

Use unit templates (`foo@.service`) and symlinks for services that need multiple instances, and timers (`*.timer`) for cron‑like scheduling.
