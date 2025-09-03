# 08 – Process Management

Processes are instances of running programs.  Understanding how to start, monitor, prioritise and terminate processes is essential for troubleshooting and performance tuning.

## Job control

Interactive shells allow you to manage foreground and background jobs:

- Start a process in the background by appending `&` (for example, `sleep 300 &`).
- Suspend the foreground job with `Ctrl‑Z`, then resume it in the background with `bg` or bring it back with `fg`.
- List your jobs with `jobs`.  Each job has a number (`%1`, `%2`) which can be passed to `bg` or `fg`.
- Use `Ctrl‑C` to send an interrupt (SIGINT) and terminate the current job.

### Example

    sleep 3600 &              # background job 1
    dd if=/dev/zero of=/dev/null &  # background job 2
    sleep 7200               # foreground job 3

Press `Ctrl‑Z` to stop the third job, type `bg` to resume it in the background and `fg %1` to bring the first job to the foreground.  Use `kill %1` to terminate it.

## Viewing processes

- `ps aux` – snapshot of all processes with owner, PID, CPU/memory usage and command.
- `ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head` – custom output sorted by CPU.
- `top` or `htop` – dynamic view of running processes.  Press `h` for help, `f` to add/remove columns, `r` to renice, `k` to kill by PID.
- `pgrep` and `pkill` – search or kill by name.  `pkill -f <pattern>` matches the full command line.

## Priorities and niceness

The kernel schedules processes based on priority; a lower “niceness” value means a higher priority.  Values range from −20 (highest priority) to +19 (lowest).

| Command | Purpose |
|-------:|---------|
| `nice -n 5 command &` | Start a command with a niceness of +5. |
| `renice -n 10 -p <PID>` | Change the niceness of a running process to +10.  Only root can decrease niceness. |

Use niceness to ensure background tasks (e.g. backups) don’t starve interactive sessions.

## Sending signals

Signals notify processes of events:

- `kill -SIGTERM <PID>` – politely ask a process to terminate (default).
- `kill -SIGKILL <PID>` – forcefully kill (cannot be caught).
- `kill -SIGHUP <PID>` – instruct a daemon to reload its configuration.
- `killall -SIGUSR1 httpd` – send a signal to all processes with the given name.

List signal names with `kill -l`.

## Projects

The `project-manage-jobs.sh` script launches several background jobs (e.g. `dd` tasks), shows how to adjust their niceness, suspend/continue them and clean them up.  Use it to explore job control, `ps`, `top`, `kill` and `renice`.  As an extension, modify it to monitor memory usage with `free -m` and report the most memory‑hungry processes.
