# Persisting and Tuning the systemd Journal

By default the systemd journal stores logs in a volatile directory (`/run/log/journal`).  This means the journal is lost on reboot.  To retain logs across restarts and control their size, follow these steps.

## 1. Create the persistent journal directory

```bash
sudo mkdir -p /var/log/journal
sudo chown root:systemd-journal /var/log/journal
sudo chmod 2755 /var/log/journal
```

The special group and setgid bit ensure new files have the correct ownership.

## 2. Restart journald

```bash
sudo systemctl restart systemd-journald
```

Check that logs persist by rebooting and running `journalctl --list-boots`.  If you see multiple boots listed, persistence is enabled.

## 3. Configure rotation

Edit `/etc/systemd/journald.conf` to tune how much space the journal can use.  Useful options include:

- `SystemMaxUse=500M` – maximum disk space used by persistent logs.
- `SystemKeepFree=100M` – amount of free space to leave on the filesystem.
- `RuntimeMaxFileSize=50M` – maximum size of individual runtime (volatile) journal files.
- `MaxRetentionSec=2week` – time limit for retaining logs.

After editing, reload the configuration:

```bash
sudo systemctl restart systemd-journald
```

Refer to `man journald.conf` for a full list of options.