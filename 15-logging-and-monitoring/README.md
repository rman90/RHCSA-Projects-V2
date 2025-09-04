# 📁 15 – Logging and Monitoring

Keeping track of what happens on your system is vital for troubleshooting and auditing.  This module focuses on configuring persistent logs, filtering rsyslog messages and exploring logs with journalctl and logrotate.

## Journald persistence

By default, journald writes logs to `/run/log/journal`, which disappears on reboot.  To persist logs, create `/var/log/journal` and set the correct ownership and permissions:

```bash
sudo mkdir -p /var/log/journal
sudo chown root:systemd-journal /var/log/journal
sudo chmod 2755 /var/log/journal
sudo systemctl restart systemd-journald
```

Check persistence with:

```bash
journalctl --list-boots
```

Edit `/etc/systemd/journald.conf` to control rotation (e.g. `SystemMaxUse`, `SystemKeepFree` and `MaxRetentionSec`).  See `man journald.conf` for details.

## rsyslog filtering

rsyslog uses facilities and priorities to direct messages to files or remote destinations.  A rule has the format:

```
facility.priority   destination
```

For example, to capture Apache errors sent via facility `local1` to `/var/log/httpd-error.log`:

```rsyslog
local1.error    /var/log/httpd-error.log
```

Place this line in `/etc/rsyslog.d/` and restart rsyslog.

The sample configuration file in this module (`rsyslog-debug-example.conf`) logs all debug messages to `/var/log/messages-debug`.  Use `logger -p daemon.debug "Test"` to generate entries.

## journalctl usage

`journalctl` can query the journal in many ways:

| Example | Description |
|--------|-------------|
| `journalctl -b` | Show messages from the current boot. |
| `journalctl -f` | Follow the log live (like `tail -f`). |
| `journalctl -u sshd.service` | Filter by systemd unit. |
| `journalctl --since '2025-01-01 00:00' --until '2025-01-02'` | Filter by time range. |
| `journalctl -p err..alert` | Show error and above priorities. |
| `journalctl _PID=1` | Filter by PID (here PID 1 – systemd). |

Practice with the script `journalctl-usage.sh`, which demonstrates various filters.

## Projects

- **journald-persistence.md** – Step‑by‑step instructions to persist and tune the journal.
- **rsyslog-debug-example.conf** – Sample rsyslog rule to log all debug messages to a separate file.
- **journalctl-usage.sh** – Script exploring different journalctl filtering options.