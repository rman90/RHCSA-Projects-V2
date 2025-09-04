# 📁 02 – User and Group Management

Managing users and groups is a core RHCSA skill.  This module explains how account information is stored, how to create and modify users, and how to delegate administrative privileges safely.

## Understanding system vs normal accounts

- User information is stored in `/etc/passwd`, with passwords hashed in `/etc/shadow` (readable only by root).  Each line of `/etc/passwd` has seven colon‑separated fields:  
  `username:password:UID:GID:comment:home:shell`.
- **UID 0** is always the superuser.  UIDs under 1 000 are reserved for system and service accounts.  Regular users start at UID 1 000 by default; these thresholds are defined in `/etc/login.defs` (`UID_MIN`, `UID_MAX`).
- The default group ID (GID) for each user is set when the account is created.  Additional group memberships are stored in `/etc/group` and `/etc/gshadow`.
- System users typically have `/sbin/nologin` or `/usr/sbin/nologin` as their shell to prevent interactive logins.

## Granting sudo privileges

On RHEL systems the `sudo` command allows a non‑root user to execute commands as another user (usually root).  To configure sudo:

1. Add the user to the `wheel` group:
   ```bash
   usermod -aG wheel username
   ```
2. Edit `/etc/sudoers` safely using `visudo` to ensure syntax correctness.  Ensure the line:
   ```
   %wheel  ALL=(ALL)       ALL
   ```
   is present to grant full sudo access to members of the wheel group.
3. To grant limited privileges to a single user, you can create a drop‑in file in `/etc/sudoers.d/`.  For example:
   ```bash
   echo "linda ALL=(ALL) /usr/sbin/useradd, /usr/bin/passwd, !/usr/bin/passwd root" \
     | sudo tee /etc/sudoers.d/linda
   ```
   This allows `linda` to run `useradd` and `passwd` but not change the root password.

Sudo authentication tokens are cached for five minutes by default.  To change this, add `Defaults timestamp_timeout=<minutes>` to `/etc/sudoers`.

> **Note:** In high‑security environments you may wish to reduce the timeout or disable caching entirely.  Conversely, increasing the timeout (e.g. `Defaults timestamp_timeout=240`) prevents repeated password prompts when you are running multiple administrative commands in quick succession.

> **Tip:** If misconfigured sudo prevents you from editing `/etc/sudoers`, use `pkexec visudo` to open it via PolicyKit.

## Creating users and groups

- **Create a group:** `groupadd devs`  
- **Create a user:** `useradd -m -s /bin/bash alice` (creates a home directory and sets the shell).
- **Assign a user to supplementary groups:** `usermod -aG devs,qa alice`
- **Remove a user:** `userdel -r alice` (removes home directory too).

You can examine account details with `getent passwd username`, `getent group groupname`, `id username` and `chage -l username` (password ageing).

System tools `vipw`/`vipw -s` and `vigr` allow you to edit `/etc/passwd`, `/etc/shadow` and `/etc/group` atomically in a text editor.  Use these only if you know exactly what you are doing – commands like `useradd` and `groupadd` handle the same changes safely.

### Batch user creation with loops

Creating many users manually is error‑prone; loops make it easy:

```bash
# Define a common password and group
COMMON_PASS="Pa55word!"
for user in joana john laura beatrix; do
  # Create the user with a home directory
  useradd -m "$user"
  # Set the password using openssl to generate a hashed value
  echo "$user:$COMMON_PASS" | chpasswd
  # Force a password change on first login
  chage -d 0 "$user"
done
```

The `chage` command controls password expiry.  Options include:

| Option | Description |
|-------:|------------|
| `-d <date>` | Set last password change date (forces expiry with `-d 0`) |
| `-m <days>` | Minimum days between password changes |
| `-M <days>` | Maximum password age |
| `-W <days>` | Warning period before expiry |
| `-E <YYYY‑MM‑DD>` | Set account expiry date |

## Default login and environment settings

New user defaults are controlled by two files:

- `/etc/login.defs` – defines UID/GID ranges, password ageing defaults, mail location and umask.
- `/etc/default/useradd` – defines the default group (`GROUP`), create home (`CREATE_HOME`), skeleton directory (`SKEL`) and default shell (`SHELL`).

The skeleton directory at `/etc/skel` contains files copied into new home directories – customise `.bashrc`, `.profile` and `.bash_logout` here to set environment variables (e.g. `export EDITOR=/usr/bin/vim`).

To change the effective primary group for file creation, use the `newgrp` command.  For example, if your primary group is `staff` and you want files you create in a shared directory to be owned by the `sales` group, run `newgrp sales` before creating the files.  You must already be a member of the target group for `newgrp` to succeed.

## Useful commands

| Command | Common options | Description |
|-------:|---------------|------------|
| `su` | `-l` run a full login shell, `-c` run a single command. | Start a new shell as another user (default root).  Requires the target user’s password; useful for testing permissions. |
| `sudo` | `-u <user>` run as another user (default root), `-k` invalidate cached credentials. | Execute a single command as root or another user according to `/etc/sudoers`.  Requires the invoking user’s password. |
| `pkexec` | *(no common options)* | Run a command as an administrator using PolicyKit; helpful if sudo is misconfigured. |
| `useradd` | `-m` create home dir; `-u` specify UID; `-g` specify primary group; `-G` specify supplementary groups; `-s` set shell; `-c` set comment. | Create a new user. |
| `usermod` | `-l` change login name; `-d` change home directory (`-m` to move files); `-s` change shell; `-aG` append to new group list; `-U` unlock an account; `-L` lock an account. | Modify an existing user. |
| `userdel` | `-r` removes the user’s home directory and mail spool. | Delete a user. |
| `passwd` | `-l` lock the account; `-u` unlock; `-e` expire immediately; `-n/-m/-x/-w` set password age values. | Set or change a password. |
| `groupadd`/`groupmod`/`groupdel` | `-g` set GID; `-n` rename group (groupmod). | Manage groups. |
| `newgrp` | *(no common options)* | Start a new shell with a different primary group; changes group ownership of new files. |
| `id` | `-u` show UID; `-g` show GID; `-G` show all groups. | Display current user and group IDs. |
| `getent` | Pass `passwd` or `group` to query the NSS database. | Query users or groups. |
| `lid` | `-g` list members of a group, `-m` list groups for a user. | Display group membership information (`lid` comes from the `libuser` package). |
| `groupmems` | `-g <group>` specify group; `-a/-d` add/delete user. | Add or remove members from a group without editing `/etc/group` directly. |
| `vipw`/`vipw -s`/`vigr` | *(no options)* | Safely edit `/etc/passwd`, `/etc/shadow` and `/etc/group` using your default editor. |

## Projects

The script in this module, `project-add-users.sh`, automates creating and configuring users, enforcing password resets and demonstrating group assignment.  It can serve as a template for your own environment provisioning.
