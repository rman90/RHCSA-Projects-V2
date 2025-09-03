# 06 – Networking Configuration

Correctly configuring network interfaces is essential for connecting to services, repositories and remote hosts.  This module covers IPv4/IPv6 addressing, `nmcli`, `nmtui`, hostnames and DNS.

## IP addressing and masks

- **IPv4** addresses consist of four octets separated by dots (e.g. `192.168.10.5`).  A subnet mask determines which portion represents the network; CIDR notation (`/24`) indicates the number of network bits.
- **IPv6** addresses are 128‑bit hexadecimal strings separated by colons (e.g. `fe80::bad:babe:1`).  Consecutive zeros may be abbreviated with `::`.
- Private IPv4 ranges: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`.  NAT allows private networks to access the Internet via a single public address.

Use `ip addr` to list addresses, `ip link` for interfaces and `ip route` to see routes and default gateways.  The `-c` option adds colour highlighting.  To add a temporary address:

```bash
sudo ip addr add 10.0.0.10/24 dev eth0
sudo ip route add default via 10.0.0.1
```

## NetworkManager

RHEL uses **NetworkManager** to manage interfaces.  Its CLI is `nmcli` and its text UI is `nmtui`.  The network state is comprised of **devices** (physical or virtual interfaces) and **connections** (profiles applied to a device).

### nmcli basics

| Command | Description |
|-------:|-------------|
| `nmcli device status` | Show devices and their state. |
| `nmcli connection show` | List configured connections. |
| `nmcli connection add type ethernet ifname eth0 con-name static ip4 192.0.2.10/24 gw4 192.0.2.1` | Create a static IPv4 connection. |
| `nmcli connection up static` | Activate a connection immediately. |
| `nmcli connection modify static ipv4.dns "8.8.8.8 8.8.4.4"` | Add DNS servers. |
| `nmcli connection modify static connection.autoconnect no` | Disable autoconnect. |
| `nmcli general hostname server1.example.com` | Set the system hostname. |

Alternatively, run `nmtui` to use a guided interface to edit connections or change the hostname.

### DNS and hostnames

DNS servers can be provided via DHCP or set manually.  The `/etc/resolv.conf` file is managed by NetworkManager; to override, use:

```bash
nmcli connection modify static ipv4.ignore-auto-dns yes
nmcli connection modify static ipv4.dns "1.1.1.1 9.9.9.9"
```

Set the system’s hostname with `hostnamectl set-hostname server1.example.com`.  Transient names are stored in `/etc/hostname`; host–IP mappings can be added to `/etc/hosts`.

## Projects

The included `project-configure-static-ip.sh` script uses `nmcli` to add a new static connection, assign an IP, set DNS servers and enable the profile.  Use it as a starting point to automate network configuration or to switch between DHCP and static profiles.
