# 📁 03 – Permissions and Access Control Lists (ACLs)

This module dives into Linux file permissions, ownership, special permission bits, default umask settings, access control lists and extended file attributes.  Mastering permissions is essential for securing services and delegating access appropriately.

## Searching for files

Two commands help locate files on a system:

| Command | When to use | Example |
|--------:|-------------|--------|
| `find`  | Precise, real‑time searches.  Traverses the filesystem and matches criteria like name, type, size, owner or modification time. | `find /etc -type f -name "hosts"` |
| `locate` | Very fast search using a prebuilt database.  Must run `sudo updatedb` to refresh the database.  Returns any path containing the search string. | `locate ssh_config` |

You can combine `find` with `-exec` to run a command on each match:

```bash
mkdir -p ~/grep-results
find /etc -type f -exec grep -l "127\.0\.0\.1" {} \; -exec cp {} ~/grep-results/ \; 2>/dev/null
```

This example copies every file under `/etc` containing `127.0.0.1` into `~/grep-results`.

## Ownership and groups

Every file has a user owner and a group owner.  The owner is allowed to modify permissions; the group owner controls access for members of that group.

- **Change owner:** `chown linda file`  
- **Change group:** either `chown :sales file` or `chgrp sales file`  
- **Change both:** `chown lisa:sales file`
- **Recursive:** add `-R` to apply changes to all items in a directory.

The `newgrp groupname` command changes your current primary group; files you create afterwards inherit that group.  Use `groups` or `id` to see your primary and supplementary groups.

## Understanding permissions

There are three permission bits for each class (user, group and others):

| Permission | Octal value | Effect on files | Effect on directories |
|-----------:|-------------|-----------------|----------------------|
| read (r)   | 4           | Can view file contents. | Can list directory entries. |
| write (w)  | 2           | Can modify file contents. | Can create, delete and rename files in the directory. |
| execute (x)| 1           | Can run the file as a program. | Can enter (`cd`) the directory. |

You can set permissions numerically or symbolically:

- **Numeric:** `chmod 640 file` sets `rw‑r‑‑‑‑` (owner read/write, group read, others none).
- **Symbolic:** `chmod u=rw,g=r,o= file` achieves the same.
- **Relative changes:** `chmod g+w,o-r file` adds group write and removes others’ read.
- **Recursive:** `chmod -R a+X /data` sets execute only on directories within `/data` (capital `X` means “execute only if directory or already executable”).

### Special bits: SUID, SGID and sticky

Unix permissions include three additional bits that change how files and directories behave:

| Bit | Octal | Symbol | Description |
|---|---|---|---|
| Set‑user‑ID (SUID) | 4xxx | `s` in the user execute position | Executable runs with the file owner’s privileges.  Example: `/usr/bin/passwd` lets any user change their password because it is owned by root and marked SUID (`-rwsr-xr-x`). |
| Set‑group‑ID (SGID) | 2xxx | `s` in the group execute position | On executables, runs with the file’s group privileges.  On directories, files created within inherit the directory’s group.  Useful for shared project directories. |
| Sticky bit | 1xxx | `t` in the others execute position | Only the file owner, directory owner or root may delete or rename files within the directory.  Common on `/tmp`. |

You can set these bits individually or all at once using octal notation:

| Mode | Description | Example |
|----:|-------------|---------|
| `chmod u+s file` | Set SUID bit on a file. | Allow `ping` to run with root privileges. |
| `chmod g+s dir` | Set SGID bit on a directory. | Ensure all files created under `/shared` belong to group `dev`. |
| `chmod +t dir` | Set sticky bit on a directory. | Protect files in `/shared/tmp` from deletion by other users. |
| `chmod 4755 file` | Set SUID and `rwx` for owner, `r-x` for group and others. | Equivalent to `u=suid,ugo=rx`. |
| `chmod 2775 dir` | Set SGID and `rwxrwxr-x` permissions. | Useful for shared group folders. |
| `chmod 1777 dir` | Set sticky bit and `rwx` for all. | The default mode of `/tmp`. |

#### Setting multiple special bits at once

The first digit of a four‑digit permission (`setuid setgid sticky`) encodes all three special bits.  Common values include:

| First digit | Bits set              | Example command             | Typical use |
|------------:|----------------------|-----------------------------|--------------|
| 0           | none                 | `chmod 0755 /usr/bin/ls`    | No special permissions (normal mode). |
| 1           | sticky               | `chmod 1777 /var/tmp`        | Protects files from deletion by others. |
| 2           | SGID                 | `chmod 2755 /srv/project`    | Ensures new files inherit the directory’s group. |
| 3           | SGID + sticky        | `chmod 3755 /srv/project`    | Combination for shared temp areas. |
| 4           | SUID                 | `chmod 4755 /usr/bin/passwd` | Runs as the file owner (root). |
| 5           | SUID + sticky        | `chmod 5755 /some/file`      | Rare; both SUID and sticky set. |
| 6           | SUID + SGID          | `chmod 6755 /usr/bin/some`   | Runs with file owner and group permissions. |
| 7           | SUID + SGID + sticky | `chmod 7755 /some/dir`       | All special bits set. |

The remaining three digits set the normal read/write/execute bits for user, group and others.

> **Note:** Avoid setting SUID to `-`20; extremely high privilege levels risk locking out other services.

## Setting default permissions with umask

When you create a file or directory the kernel applies a maximum permission mask (666 for files, 777 for directories) minus the **umask** value.  You can view your current umask with `umask` and set it in your shell or globally in `/etc/profile`.

For example, a umask of `022` subtracts write permission for group and others: files become `644` (`666‑022`), directories become `755` (`777‑022`).  A restrictive umask like `077` yields `600` for files and `700` for directories.

## Extended ACLs

Traditional UNIX permissions only allow one owner and one group.  **Access control lists (ACLs)** enable fine‑grained permissions for additional users and groups.  Commands include:

- `getfacl file` – display ACLs for a file or directory.
- `setfacl -m u:alice:rw file` – grant user `alice` read/write access.
- `setfacl -m g:qa:r file` – grant group `qa` read permission.
- `setfacl -m d:u:alice:rw dir` – set a **default** ACL for a directory (applies to newly created items).
- `setfacl -x u:alice file` – remove an ACL entry.

ACLs are persistent; ensure the filesystem is mounted with the `acl` option if necessary.

## Extended file attributes

The `chattr` command controls low‑level attributes on ext4/xfs filesystems:

| Attribute | Description |
|----------|-------------|
| `A` | Don’t update access time (`atime`) when reading the file (improves performance). |
| `a` | Append‑only; allows writing but prevents truncation or deletion. |
| `c` | Enable compression (requires filesystem support). |
| `D` | Synchronous updates; write changes directly to disk (useful for databases). |
| `d` | Exclude file from dumps made by the legacy `dump` program. |
| `i` | Immutable; file cannot be changed, deleted or renamed.  Even root must remove this bit (`chattr -i file`) first. |
| `s` | Secure deletion; overwrites blocks with zeroes upon removal. |
| `u` | Undelete; allows recovery utilities to restore deleted files. |

List attributes with `lsattr`; change them with `chattr +i file` or `chattr -i file`.

## Useful commands

| Command | Common options | Description |
|-------:|---------------|------------|
| `chmod` | `-R` recursive; `u/g/o/a` to specify user/group/others/all; `+/-/=` to add/remove/set exact permissions; numeric notation like `755` or `2755`. | Change file permissions. |
| `chown` | `-R` recursive; `user:group` to change both; `:group` to change only group. | Change file owner and/or group. |
| `chgrp` | `-R` recursive. | Change file group owner only (wrapper around `chown :group`). |
| `umask` | With no arguments prints current mask; when set (e.g. `umask 027`) affects new files for the current shell. | Set default permission mask for new files. |
| `getfacl`/`setfacl` | `-m` to modify, `-x` to remove, `-R` to apply recursively, `-d` to set default ACL. | View and modify ACLs. |
| `lsattr`/`chattr` | `-R` for recursion, `+i`/`-i` to add/remove immutable bit. | View and change extended file attributes. |
| `find` | `-type d`/`-type f` filter by type; `-name "*.conf"` match names; `-user`/`-group` filter by owner; `-size +1M` filter by size; `-exec <cmd> {} \;` execute a command per match; `-print0 ... | xargs -0 ...` handles spaces. | Search for files/directories. |
| `locate` | `-i` ignore case; `--regex` treat pattern as a regular expression; needs updatedb. | Search quickly using a prebuilt database. |

## Projects

This module comes with two example scripts that you can run as root on a test system.  Each script is self‑contained and prints progress messages so you can follow what it’s doing.

### project‑file‑acl.sh

This script creates two groups (`dev` and `qa`), two users (`devuser` and `qauser`), builds a shared directory under `/shared/projectX`, assigns ownership and basic UNIX permissions, and then applies Access Control Lists so that the QA user and group can read/write the file.  It finishes by listing the resulting permissions and ACL entries.

Run it with:

```bash
sudo bash project-file-acl.sh
```

After running, explore `/shared/projectX` to see the ACLs and experiment with adding additional files.

### project‑permission‑audit.sh

The second script audits a directory tree for insecure permissions.  It searches for world‑writable files, directories missing the SGID bit and files that are not owned by the expected group.  You can specify a directory and an expected group; if omitted it defaults to `/shared/projectX` and group `dev`.

Run it like this to audit `/shared/projectX` for files not group‑owned by `dev`:

```bash
sudo bash project-permission-audit.sh /shared/projectX dev
```

The script reports each problem and exits with a summary.  You can use it as a starting point for your own compliance checks.

---

As an additional exercise, try using `find` to recursively set the SGID bit on all subdirectories of `/shared/projectX`:

```bash
find /shared/projectX -type d -exec chmod g+s {} \;
```

You might also write a script that compares the permissions of files under a directory against a baseline and warns about deviations.  Our `project-permission-audit.sh` demonstrates one possible approach – experiment!
