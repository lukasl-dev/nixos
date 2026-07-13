# NixOS container removal: state migration

The configuration no longer starts the `lukasl-dev` NixOS container. Before
switching Pollux to this configuration, move persistent service state from the
container root to the corresponding host paths.

## Migration script

Run the conservative preflight first:

```console
sudo ./scripts/migrate-galaxy-state.sh --dry-run
```

To stop the mapped services and perform the copy, execute it with:

```console
sudo ./scripts/migrate-galaxy-state.sh --execute
```

The script stops matching systemd services inside the running NixOS container,
as well as matching host units if present, and deliberately leaves them stopped
for cutover. It copies each source into a temporary sibling and verifies it with
a checksum-based `rsync` dry run before changing the destination. An existing
destination is renamed to `<destination>.bak-<UTC timestamp>`. It never deletes
source data, existing backups, failed temporary copies, or the container root.
Missing source directories are skipped because not every service was enabled in
every container.

## Safety

1. Back up `/var/lib/nixos-containers/lukasl-dev` in full.
2. Stop the container before copying mutable state.
3. Do not delete the old container root until every service and backup has been
   verified.
4. Check destination ownership against the users created by the new host
   configuration. Do not assume that numeric user IDs inside the old container
   match host user IDs, especially for services using systemd `DynamicUser` and
   `/var/lib/private`.

## Pollux state map

| Service | Source below `/var/lib/nixos-containers/lukasl-dev` | Host destination |
| --- | --- | --- |
| Anki | `/var/lib/private/anki-sync-server` | `/var/lib/private/anki-sync-server` |
| Audiobookshelf | `/var/lib/audiobookshelf` | `/var/lib/audiobookshelf` |
| Homebox | `/var/lib/homebox` | `/var/lib/homebox` |
| Radicale | `/var/lib/radicale` | `/var/lib/radicale` |
| Factorio | `/var/lib/private/factorio` | `/var/lib/private/factorio` |
| Forgejo and runner | `/var/lib/forgejo` | `/var/lib/forgejo` |
| Pi-hole configuration | `/etc/pihole` | `/etc/pihole` |
| Pi-hole state | `/var/lib/pihole` | `/var/lib/pihole` |
| Home Assistant | `/var/lib/hass` | `/var/lib/hass` |
| Grocy | `/var/lib/grocy` | `/var/lib/grocy` |
| Tuwunel | `/var/lib/private/tuwunel` | `/var/lib/private/tuwunel` |
| NetBird | `/var/lib/netbird` | `/var/lib/netbird` |
| Uptime Kuma | `/var/lib/private/uptime-kuma` | `/var/lib/private/uptime-kuma` |
| Vaultwarden | `/var/lib/vaultwarden` | `/var/lib/vaultwarden` |
| Wakapi | `/var/lib/private/wakapi` | `/var/lib/private/wakapi` |
| Yamtrack | `/var/lib/yamtrack` | `/var/lib/yamtrack` |
| Yamtrack Redis | `/var/lib/yamtrack-redis` | `/var/lib/yamtrack-redis` |

`/var/www/notes` and `/var/www/www` were host bind mounts, so they should
already be in their final locations. Attic, Maddy/Rspamd, and Coturn already ran
on the host and do not need container-state migration.

Ida already ran Home Assistant, Pi-hole, and the restic REST server in host
mode, so no container-state migration is expected there.

## Suggested cutover

1. Record the current service status and take application-aware backups where
   available.
2. Run the script with `--dry-run`.
3. Run the script with `--execute`; it stops the mapped services inside the
   container and any matching host units, then leaves them stopped.
4. Review its log under `/var/log`.
5. Check ownership against the new host service users.
6. Switch to the host-only configuration and start its services.
7. Verify local listeners, Traefik routes, ACME certificates, Forgejo SSH,
   Factorio, mail, and restic backups.
8. Retain the old container root and all `.bak-*` directories until at least one
   successful backup cycle has completed.
