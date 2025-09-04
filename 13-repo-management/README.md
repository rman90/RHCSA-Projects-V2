# 📁 13 – Software and Repository Management

Installing, updating and removing software is a fundamental administrator task.  RHEL uses RPM packages managed by the DNF package manager.  This module covers RPM/DNF basics, module streams and setting up a simple local repository.

## RPM basics

- **Query an installed package:** `rpm -q bash`
- **List files in a package:** `rpm -ql bash`
- **Find which package owns a file:** `rpm -qf /usr/bin/ls`
- **Verify a package:** `rpm -V bash`

RPM packages have metadata including version, release and architecture.  They do not resolve dependencies when installed manually; use DNF instead.

## DNF commands

| Command | Description |
|-------:|-------------|
| `dnf search <pattern>` | Search available packages. |
| `dnf info <pkg>` | Show detailed information. |
| `dnf install <pkg>` | Install a package and its dependencies. |
| `dnf remove <pkg>` | Remove a package. |
| `dnf update` | Update all packages to the latest versions. |
| `dnf history list` | List past transactions.  Use `dnf history undo <id>` to undo. |
| `dnf provides <file>` | Find which package contains a file. |

### Module streams

RHEL AppStream repositories contain multiple versions of certain software.  Use `dnf module list` to view available streams, `dnf module enable <name>:<stream>` to select a version and `dnf module install <name>` to install the stream.  Disable a stream with `dnf module reset <name>`.

## Creating a local repository

On disconnected systems you may need a local repository.  The basic steps:

1. **Gather RPMs** – Copy the required `.rpm` packages into a directory (e.g. `/srv/repos/baseos`).
2. **Create repository metadata** – Install `createrepo_c` and run:
   ```bash
   createrepo_c /srv/repos/baseos
   ```
   This creates the `repodata` directory with metadata.
3. **Serve the repo** – You can share via HTTP, NFS or a local path.  For HTTP, install Apache (`httpd`) and create a site that points to `/srv/repos`.  For NFS, export the directory in `/etc/exports`.
4. **Create a repo file on clients** – Add a file under `/etc/yum.repos.d/local.repo`:
   ```ini
   [local-baseos]
   name=Local BaseOS
   baseurl=file:///srv/repos/baseos
   enabled=1
   gpgcheck=0
   ```
   Replace `file:///` with `http://server/repo` or `nfs://` as appropriate.

## Projects

- **create-local-repo.sh** – Automates creating a local repository from a directory of RPMs and writes a corresponding `.repo` file.  Use it on a lab machine to practice building and enabling your own repos.