# 20 – Software Management with RPM and DNF

This module consolidates everything you need to know about installing, removing and managing software on RHEL using the RPM package format and the DNF package manager.

## Understanding RPM packages

RPM packages (`.rpm` files) contain software binaries and metadata.  Key commands:

| Command | Description |
|-------:|-------------|
| `rpm -q <pkg>` | Query if a package is installed. |
| `rpm -qi <pkg>` | View package information. |
| `rpm -ql <pkg>` | List files installed by the package. |
| `rpm -qf <file>` | Find which package owns a file. |
| `rpm -V <pkg>` | Verify package files against the RPM database. |

You can install an RPM manually with `rpm -i package.rpm`, but dependency resolution is not automatic.  Instead use DNF.

## Using DNF

DNF is the front‑end to the RPM system.  Basic usage:

- Install packages: `dnf install httpd mariadb-server`
- Update packages: `dnf update`
- Remove packages: `dnf remove httpd`
- Search packages: `dnf search nginx`
- Show package info: `dnf info postgresql`
- List installed packages: `dnf list installed`
- Check for updates: `dnf check-update`
- History and rollbacks: `dnf history list`, `dnf history info <id>`, `dnf history undo <id>`

### Working with AppStream modules

RHEL splits packages into BaseOS (always available) and AppStream (multiple versions).  Modules allow you to choose a specific version.  Example:

```bash
dnf module list nodejs
dnf module enable nodejs:18
dnf install nodejs
```

Reset a module to switch versions:

```bash
dnf module reset nodejs
dnf module enable nodejs:20
dnf update
```

### Repository configuration

DNF reads `.repo` files under `/etc/yum.repos.d`.  Each file defines one or more repos with:

```
[name]
name=Human readable description
baseurl=http://server/path/ or file:///path/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
``` 

The RHCSA exam often requires creating a local repo from an ISO image.  Use `mount -o loop RHEL-9-x86_64-dvd.iso /mnt` and write a `.repo` file pointing at `file:///mnt/BaseOS` and `file:///mnt/AppStream`.

## Projects

- Practise enabling and installing different module streams (e.g. `php:8.0` vs `php:8.1`).
- Use the `create-local-repo.sh` script in Module 13 to build your own repo and then configure DNF to use it.
- Explore `dnf history` to undo an installation and compare system state before and after.