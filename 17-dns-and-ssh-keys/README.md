# 📁 17 – DNS and SSH Key Management

This module covers configuring hostname and DNS resolution on RHEL and managing SSH public keys for secure authentication.

## Configuring DNS

DNS translates hostnames to IP addresses.  On RHEL, NetworkManager manages `/etc/resolv.conf`.  You can set DNS servers per connection:

```bash
nmcli connection modify static ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection modify static ipv4.ignore-auto-dns yes
nmcli connection up static
```

Use `systemd-resolved` for stub resolver features (`resolvectl` replaces `systemd-resolve`):

```bash
resolvectl status
resolvectl query example.com
```

For local overrides, edit `/etc/hosts`:

```
192.168.1.100   intranet.example.com intranet
```

## Running a caching DNS server

Install `bind` and create a simple caching nameserver by enabling the `named` service.  Modify `/etc/named.conf` to allow queries from your network and set `forwarders` to upstream DNS servers.  Then point clients’ `resolv.conf` or NetworkManager DNS settings to the server’s IP.

## Managing SSH keys

SSH key authentication eliminates password prompts and is more secure.  Key management steps:

1. **Generate a key pair** on the client:
   ```bash
   ssh-keygen -t ed25519 -C "work@example.com"
   ```
   The private key is stored in `~/.ssh/id_ed25519`; never share it.

2. **Install the public key** on the server:
   ```bash
   ssh-copy-id user@server
   ```
   This appends your key to `~user/.ssh/authorized_keys` on the server.

3. **Verify permissions** – The `.ssh` directory on the server should be mode `700` and `authorized_keys` should be `600`.  Incorrect permissions may cause SSH to ignore the file.

4. **Manage known hosts** – SSH stores host keys in `~/.ssh/known_hosts`.  If a server’s key changes (e.g. after reinstall) remove the old entry with `ssh-keygen -R hostname` to avoid man‑in‑the‑middle warnings.

## Additional tips

- Use the `-o IdentitiesOnly=yes` option when invoking SSH if you have multiple keys but only want to use the specified identity.
- The `ssh-agent` and `ssh-add` commands cache decrypted keys so you only enter passphrases once per session.
- For script automation, you can force a command on the server by prefixing it with your key in `authorized_keys` (e.g. `command="rsync --server ..." ssh-rsa AAAA...`).