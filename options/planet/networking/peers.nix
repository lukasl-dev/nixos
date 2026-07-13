{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.planet.networking.peers;
  client = config.services.netbird.clients.peers;
  clientCommand = lib.getExe client.wrapper;
in
{
  options.planet.networking.peers = {
    enable = lib.mkEnableOption "the NetBird peer client";

    managementUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://peers.${config.planet.domain}:443";
      description = "NetBird management and dashboard URL.";
    };

    setupKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/agenix/netbird-setup-key";
      description = ''
        Optional file containing a NetBird setup key. When set, an idempotent
        oneshot service enrolls the peer without copying the key to the Nix store.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.netbird = {
      package = pkgs.unstable.netbird;
      ui.package = pkgs.unstable.netbird-ui;

      clients.peers = {
        port = 51820;
        interface = "nb-peers";
        hardened = true;
        autoStart = true;
        openFirewall = true;

        environment = {
          NB_MANAGEMENT_URL = cfg.managementUrl;
          NB_ADMIN_URL = cfg.managementUrl;
        };

        config = {
          ManagementURL = cfg.managementUrl;
          AdminURL = cfg.managementUrl;
        };
      };
    };

    users.users.${config.planet.user.name}.extraGroups = [ client.user.group ];

    # NetBird's management policy is the authority for traffic arriving over
    # the overlay, matching the existing Tailscale setup during migration.
    networking.firewall.trustedInterfaces = [ client.interface ];

    systemd.services.netbird-peers-enroll = lib.mkIf (cfg.setupKeyFile != null) {
      description = "Enroll this machine as a NetBird peer";
      wantedBy = [ "multi-user.target" ];
      requires = [ "${client.service.name}.service" ];
      after = [ "${client.service.name}.service" ];

      script = ''
        set -euo pipefail

        for _ in $(seq 1 30); do
          if ${clientCommand} status --json >/dev/null 2>&1; then
            break
          fi
          sleep 1
        done

        if ${clientCommand} status --json 2>/dev/null \
          | ${lib.getExe pkgs.jq} -e '.management.connected == true' >/dev/null; then
          exit 0
        fi

        ${clientCommand} up \
          --management-url ${lib.escapeShellArg cfg.managementUrl} \
          --admin-url ${lib.escapeShellArg cfg.managementUrl} \
          --setup-key-file "$CREDENTIALS_DIRECTORY/setup-key"
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = "setup-key:${toString cfg.setupKeyFile}";
      };
    };
  };
}
