# 07 – Routing, VLANs and NAT

When your server acts as a router or gateway it must forward traffic between networks.  In RHCSA you may be asked to add static routes, configure VLAN interfaces or set up simple NAT.  Firewalld makes these tasks straightforward.

## Static routes

A *route* determines the next hop for traffic destined to a particular network.  Use `ip route` to view and manipulate routes:

- Show current routes: `ip route show`
- Add a route: `ip route add 10.50.0.0/16 via 192.0.2.254 dev eth1`
- Delete a route: `ip route del 10.50.0.0/16 via 192.0.2.254`
- Make routes persistent by editing a connection:  
  `nmcli connection modify static +ipv4.routes "10.50.0.0/16 192.0.2.254"`

Verify with `ip route` or `nmcli connection show static`.

## VLANs

Virtual LANs allow multiple logical networks to share a single physical interface.  VLAN interfaces are named `<iface>.<vlanid>` (e.g. `eth0.10`).  Use `nmcli` to create them:

```bash
nmcli connection add type vlan con-name vlan10 ifname vlan10 dev eth0 id 10 ip4 192.0.2.2/24
nmcli connection up vlan10
```

Alternatively, add `VLAN=yes` and `VLAN_ID=10` to the interface file under `/etc/sysconfig/network-scripts`.

## Network Address Translation (NAT)

If your server connects an internal network to the Internet, NAT translates internal addresses to the server’s public address.  Firewalld provides a masquerade feature to enable NAT:

1. Ensure IP forwarding is enabled:
   ```bash
   echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
   sysctl -p
   ```
2. Enable masquerading for the *external* zone:
   ```bash
   firewall-cmd --permanent --zone=external --add-interface=eth1
   firewall-cmd --permanent --zone=external --add-masquerade
   firewall-cmd --permanent --zone=internal --add-interface=eth0
   firewall-cmd --reload
   ```

Inbound traffic from the external network can then be forwarded to internal hosts via port forwarding rules (DNAT).

## Projects

The `project-setup-nat-routing.sh` script configures IP forwarding, assigns interfaces to zones and enables masquerading on a lab machine.  Adapt it for your own networks by adjusting the interface names and zones.
