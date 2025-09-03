# 09 – Scheduling Tasks

Automating tasks frees administrators from manual repetition.  RHEL supports three major scheduling mechanisms: cron, at and systemd timers.

## Cron

Cron runs commands at fixed times or intervals based on rules in crontab files.  Users may have their own crontabs, while system‑wide jobs live in `/etc/crontab` and `/etc/cron.*`.

A crontab entry consists of five fields (minute, hour, day of month, month, day of week) followed by the command:

```
# m h dom mon dow user    command
30 2 * * * root /usr/local/sbin/backup.sh
```

Edit your crontab with `crontab -e`.  List it with `crontab -l`.  Remove it with `crontab -r`.

### Environment variables in cron

Cron provides a minimal environment.  If your job fails because commands aren’t found or variables aren’t set, you need to define them manually at the top of the crontab:

```
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
MAILTO=""
```

You can also prefix variables for a single job:

```bash
0 1 * * * VAR1=foo VAR2=bar /path/to/script.sh
```

To debug environmental issues, output `env` to a log file from within your script and compare it to your interactive shell.

## at and batch

`at` schedules one‑off commands to run at a specific time:

```bash
echo "systemctl restart httpd" | at 23:30
at -l         # list pending jobs
at -c <job>   # view job script
atrm <job>    # delete job
```

The `batch` command runs jobs when system load permits.

## systemd timers

Systemd can replace cron with timer units (`*.timer`) that trigger service units (`*.service`).  Timers support calendar expressions (`OnCalendar=Mon *-*-1..7 00:00:00`) and monotonic triggers (`OnBootSec=30min`).  Use `systemctl list-timers` to see active timers.

## Projects

The `project-cron-audit.sh` script enumerates the current user’s cron jobs, verifies that environment variables are set as expected and schedules a one‑off task with `at`.  As an extension, write a timer unit that runs `dnf update` weekly with proper time zone settings.
