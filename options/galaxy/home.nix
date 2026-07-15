{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.galaxy) domain home;

  listenAddress = "0.0.0.0";
  proxyAddress = "127.0.0.1";
  stateDir = "/var/lib/hass";

  hass = pkgs.unstable.home-assistant;
  hassPythonPackages = hass.python3Packages or (hass.python.pkgs or hass.passthru.python.pkgs);

  greeClimateComponent = pkgs.unstable.buildHomeAssistantComponent rec {
    owner = "RobHofmann";
    domain = "gree";
    version = "3.6.0";

    src = pkgs.unstable.fetchFromGitHub {
      inherit owner;
      repo = "HomeAssistant-GreeClimateComponent";
      rev = version;
      hash = "sha256-L46+PRg7kxByMJ5vjNHgEx2QQSFib9H0UMW1eVayCQM=";
    };

    dependencies = with hassPythonPackages; [
      aiofiles
      pycryptodome
    ];

    meta = {
      description = "Custom Gree climate component for Home Assistant";
      homepage = "https://github.com/RobHofmann/HomeAssistant-GreeClimateComponent";
      license = lib.licenses.gpl3Only;
    };
  };

  module = {
    services.home-assistant = {
      enable = true;

      package = hass;

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
        "solax"
        "shelly"
        "vesync"
        "reolink"

        # Zigbee Home Automation for the SONOFF Dongle Max (EFR32MG24), using
        # either its Ethernet/TCP endpoint or its USB serial connection. The
        # NixOS module also grants Home Assistant serial-device access when
        # this component is enabled.
        "zha"
      ];

      customComponents = [
        greeClimateComponent
      ];

      config = {
        default_config = { };

        # Keep UI-created automations in Home Assistant's mutable state dir.
        automation = "!include automations.yaml";

        http = {
          server_host = listenAddress;
          server_port = home.port;
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
            "::1"
          ];
        };
      };
    };
  };
in
{
  options.galaxy = {
    home = {
      enable = lib.mkEnableOption "Enable Home Assistant";

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
      module
      {
        # Make Home Assistant reachable directly from the local network. The
        # home.lukasl.dev reverse-proxy route remains mesh-only below.
        networking.firewall.allowedTCPPorts = [ home.port ];

        galaxy = {
          backup.paths = [ stateDir ];
          proxy.rules = [
            {
            name = "home";
            from = {
              host = home.host;
              meshOnly = true;
            };
              to.http = "http://${proxyAddress}:${toString home.port}";
            }
          ];
        };
      }
    ]
  );
}
