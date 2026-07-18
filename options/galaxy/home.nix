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

  tplinkDecoComponent = pkgs.unstable.buildHomeAssistantComponent rec {
    owner = "amosyuen";
    domain = "tplink_deco";
    version = "3.9.2";

    src = pkgs.unstable.fetchFromGitHub {
      inherit owner;
      repo = "ha-tplink-deco";
      rev = "59f5b361cf00df2721a499d37751613423d3d8d3";
      hash = "sha256-AeEWKGIRwiro6J0ShrlJ4MnVl0Oxmi5KYav0RWLh6xo=";
    };

    dependencies = with hassPythonPackages; [
      pycryptodome
    ];

    meta = {
      changelog = "https://github.com/amosyuen/ha-tplink-deco/releases/tag/v${version}";
      description = "TP-Link Deco custom integration for Home Assistant";
      homepage = "https://github.com/amosyuen/ha-tplink-deco";
      license = lib.licenses.mit;
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
      {
        services.home-assistant = {
          enable = true;

          package = hass;

          extraComponents = [
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

            "zha"
          ];

          customComponents = [
            greeClimateComponent
            tplinkDecoComponent
          ];

          config = {
            default_config = { };

            # keep ui-created automations in home assistant's mutable state dir
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
      }

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
                inherit (home) host;
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
