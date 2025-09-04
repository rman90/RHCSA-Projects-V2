# 📁 16 – Networking Services

In addition to configuring interfaces and firewalls, the RHCSA exam expects you to set up and secure common network services.  This module covers SSH for remote administration, Apache HTTPD for web serving and NFS/autofs for network file sharing.

## Secure Shell (SSH)

### Installing and starting the service

The OpenSSH server package is `openssh-server`.  Install and enable it:

```bash
sudo dnf install -y openssh-server
sudo systemctl enable --now sshd.service
```

Check status with `systemctl status sshd`.  Use `ssh user@host` to connect; specify a different port with `-p <port>`.  Server settings are in `/etc/ssh/sshd_config` (listen port, PermitRootLogin, PasswordAuthentication, AllowUsers).  After changes, restart SSH with `systemctl restart sshd`.

### Key‑based authentication

Generate a key pair on the client:

```bash
ssh-keygen -t rsa -b 4096 -C "you@example.com"
# accepts default path ~/.ssh/id_rsa and optional passphrase
```

Copy the public key to the server:

```bash
ssh-copy-id user@server
```

This appends your key to `~user/.ssh/authorized_keys` on the server.  Disable password logins by setting `PasswordAuthentication no` in `sshd_config` for stronger security.

## Apache HTTPD

Install the web server:

```bash
sudo dnf groupinstall -y "Basic Web Server"
sudo systemctl enable --now httpd.service
```

The main configuration file is `/etc/httpd/conf/httpd.conf`; additional virtual hosts live in `/etc/httpd/conf.d/`.  The default document root is `/var/www/html`.  Change `DocumentRoot` and add a `<Directory>` block to grant access to a different directory.  To serve on a non‑default port, change the `Listen` directive and update SELinux port contexts with `semanage port -a -t http_port_t -p tcp 8080`.

## NFS and autofs

### Exporting a share

On the NFS server install `nfs-utils`, create a directory (e.g. `/srv/nfs/share`) and add it to `/etc/exports`:

```
/srv/nfs/share  *(rw,no_root_squash,sync)
```

Start and enable NFS services:

```bash
sudo systemctl enable --now nfs-server.service
sudo systemctl enable --now rpcbind.service mountd.service
```

Open firewall ports:

```bash
firewall-cmd --permanent --add-service={nfs,mountd,rpc-bind}
firewall-cmd --reload
```

Verify exports with `showmount -e server`.

### Mounting from a client

Install `nfs-utils` and mount manually:

```bash
sudo dnf install -y nfs-utils
sudo mount server:/srv/nfs/share /mnt
```

Add to `/etc/fstab` for persistent mounts:

```
server:/srv/nfs/share   /mnt/nfs   nfs   defaults,_netdev   0 0
```

### Using autofs

The `autofs` service automatically mounts NFS shares on demand and unmounts them after a period of inactivity.  Install it:

```bash
sudo dnf install -y autofs
```

Add a line to `/etc/auto.master` pointing to a map file, then create the map.  Example:

```
/nfs   /etc/auto.nfs
```

The `/etc/auto.nfs` file might contain:

```
share   -rw   server:/srv/nfs/share
```

Enable autofs:

```bash
sudo systemctl enable --now autofs
```

Access `/nfs/share` and autofs mounts it on demand.