{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;

  cfg = config.planet.networking.peers;
  client = config.services.netbird.clients.peers;
  clientCommand = lib.getExe client.wrapper;

  setupKey = "galaxy/peers/setupKey";
  managementHost = "peers.${config.planet.domain}:443";
  managementUrl = "https://${managementHost}";
  managementUrlConfig = {
    Scheme = "https";
    Host = managementHost;
  };
in
{
  options.planet.networking.peers.enable = lib.mkEnableOption "the NetBird peer client";

  config = lib.mkIf cfg.enable {
    age.secrets.${setupKey}.rekeyFile = ../../../secrets/galaxy/peers/setupKey.age;

    services.netbird = {
      package = pkgs.unstable.netbird;
      ui.package = pkgs.unstable.netbird-ui;

      clients.peers = {
        port = 51820;
        interface = "nb-peers";

        # Binding a fixed address makes NetBird DNS reliable and causes the
        # hardened NixOS service to receive CAP_NET_BIND_SERVICE.
        dns-resolver.address = "127.0.0.153";

        # NetBird 0.73 serializes net/url.URL values as JSON objects.
        config = {
          ManagementURL = managementUrlConfig;
          AdminURL = managementUrlConfig;
        };
      };
    };

    users.users.${config.planet.user.name}.extraGroups = [ client.user.group ];
    networking.firewall.trustedInterfaces = [ client.interface ];

    systemd.services.netbird-peers-enroll = {
      description = "Enroll this machine as a NetBird peer";
      wantedBy = [ "multi-user.target" ];
      requires = [ "${client.service.name}.service" ];
      after = [ "${client.service.name}.service" ];

      script = ''
        set -euo pipefail

        for _ in $(seq 1 30); do
          if ${clientCommand} status --json 2>/dev/null \
            | ${lib.getExe pkgs.jq} -e '.management.connected == true' >/dev/null; then
            exit 0
          fi
          sleep 1
        done

        ${clientCommand} up \
          --management-url ${managementUrl} \
          --admin-url ${managementUrl} \
          --setup-key-file "$CREDENTIALS_DIRECTORY/setup-key"
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = "setup-key:${age.secrets.${setupKey}.path}";
      };
    };
  };
}
