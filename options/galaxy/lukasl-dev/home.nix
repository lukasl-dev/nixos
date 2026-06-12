{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.galaxy.lukasl-dev) addresses domain home;

  isGuest = home.mode == "guest";
  listenAddress = if isGuest then addresses.local else "0.0.0.0";
  proxyAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/hass";

  module = {
    services.home-assistant = {
      enable = true;

      package = pkgs.unstable.home-assistant;

      extraComponents = [
        # Components required/recommended for onboarding and a basic setup.
        "analytics"
        "default_config"
        "esphome"
        "google_translate"
        "isal"
        "met"
        "cast"
        "ipp"
        "speedtestdotnet"

        "ecovacs"
        "gree"
        "solax"
        "shelly"
        "vesync"
        "reolink"
      ];

      config = {
        default_config = { };

        http = {
          server_host = listenAddress;
          server_port = home.port;
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
            "::1"
            addresses.host
          ];
        };
      };
    };

    # The container firewall needs to allow Home Assistant for forwarded
    # requests from the host.
    networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ home.port ];
  };
in
{
  options.galaxy.lukasl-dev = {
    home = {
      enable = lib.mkEnableOption "Enable Home Assistant";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run Home Assistant in the lukasl-dev container or on the host.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8123;
        readOnly = true;
        description = "Port for Home Assistant.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "home.${domain}";
        readOnly = true;
        description = "Public hostname for Home Assistant.";
      };
    };
  };

  config = lib.mkIf home.enable (
    lib.mkMerge [
      {
        # Make Home Assistant reachable directly from the local network. The
        # home.lukasl.dev reverse-proxy route remains tailscale-only below.
        networking.firewall.allowedTCPPorts = [ home.port ];

        galaxy.lukasl-dev = {
          backup.paths = [
            (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
          ];

          proxy.rules = [
            {
              type = "https";
              name = "home";
              from = {
                host = home.host;
                tailscaleOnly = true;
              };
              to.http = "http://${proxyAddress}:${toString home.port}";
            }
          ];

          modules.home = {
            inherit (home) mode;
            inherit module;
          };
        };
      }

      (lib.mkIf isGuest {
        containers.lukasl-dev.forwardPorts = [
          {
            protocol = "tcp";
            hostPort = home.port;
            containerPort = home.port;
          }
        ];
      })

      (lib.mkIf (!isGuest) module)
    ]
  );
}
