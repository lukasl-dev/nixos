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
            "forecast_solar"
            "pi_hole"

            "ecovacs"
            "solax"
            "shelly"
            "vesync"
            "reolink"
            "tuya"

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
                # netbird-proxy reaches peer targets through the mesh and
                # forwards the original client address.
                "100.64.0.0/10"
              ];
              ip_ban_enabled = true;
              login_attempts_threshold = 5;
            };

            template = [
              {
                sensor = [
                  {
                    name = "Total PV Power";
                    unique_id = "solax_total_pv_power";
                    unit_of_measurement = "W";
                    device_class = "power";
                    state_class = "measurement";
                    availability = # jinja
                      ''
                        {{ is_number(states('sensor.solax_pv1_power'))
                           and is_number(states('sensor.solax_pv2_power'))
                           and is_number(states('sensor.solax_pv3_power')) }}
                      '';
                    state = # jinja
                      ''
                        {% set pv1 = states('sensor.solax_pv1_power') %}
                        {% set pv2 = states('sensor.solax_pv2_power') %}
                        {% set pv3 = states('sensor.solax_pv3_power') %}
                        {% if is_number(pv1) and is_number(pv2) and is_number(pv3) %}
                          {{ (pv1 | float) + (pv2 | float) + (pv3 | float) }}
                        {% endif %}
                      '';
                  }
                  {
                    name = "Total Battery Power";
                    unique_id = "solax_total_battery_power";
                    unit_of_measurement = "W";
                    device_class = "power";
                    state_class = "measurement";
                    availability = # jinja
                      ''
                        {{ is_number(states('sensor.solax_battery_1_power'))
                           and is_number(states('sensor.solax_battery_2_power')) }}
                      '';
                    state = # jinja
                      ''
                        {% set battery1 = states('sensor.solax_battery_1_power') %}
                        {% set battery2 = states('sensor.solax_battery_2_power') %}
                        {% if is_number(battery1) and is_number(battery2) %}
                          {{ (battery1 | float) + (battery2 | float) }}
                        {% endif %}
                      '';
                  }
                ];
              }
            ];
          };
        };
      }

      {
        # Make Home Assistant reachable directly from the local network. The
        # route below remains a mesh-only fallback; public traffic is carried
        # from Pollux to this port by NetBird's reverse proxy.
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
