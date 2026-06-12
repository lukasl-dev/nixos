{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev) addresses domain home;

  isGuest = home.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/hass";

  module = {
    services.home-assistant = {
      enable = true;

      extraComponents = [
        # Components required/recommended for onboarding and a basic setup.
        "analytics"
        "default_config"
        "esphome"
        "google_translate"
        "isal"
        "met"
        "radio_browser"
        "shopping_list"
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
              to.http = "http://${listenAddress}:${toString home.port}";
            }
          ];

          modules.home = {
            inherit (home) mode;
            inherit module;
          };
        };
      }

      (lib.mkIf (!isGuest) module)
    ]
  );
}
