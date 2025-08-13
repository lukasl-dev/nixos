# pollux

## Networking

- **IPv4:** `185.245.61.227/24`
    - **Default Gateway:** `185.245.61.1`

**Bootstrap networking:**

```bash
sudo ip link set dev ens18 down
sudo ip addr flush dev ens18
sudo ip addr add 185.245.61.227/24 dev ens18
sudo ip link set dev ens18 up
sudo ip route flush default
sudo ip route add default via 185.245.61.1 dev ens18

printf 'nameserver 1.1.1.1\nnameserver 1.0.0.1\n' | sudo tee /etc/resolv.conf >/dev/null
```

If systemd-resolved is active, configure DNS with `resolvectl` instead of editing `/etc/resolv.conf`:

```bash
sudo resolvectl dns ens18 1.1.1.1 1.0.0.1
# Route all domains via this link's DNS during bootstrap (optional)
sudo resolvectl domain ens18 ~.
# Verify
resolvectl status ens18
```
