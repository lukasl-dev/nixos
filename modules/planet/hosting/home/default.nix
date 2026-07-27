{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) domain;
  inherit (config.planet.hosting) home;
  inherit (atlas.hosting.home) host;

  listenAddress = "0.0.0.0";
  proxyAddress = "127.0.0.1";
  port = 8123;
  stateDir = "/var/lib/hass";

  hass = pkgs.unstable.home-assistant.override {
    packageOverrides = _final: previous: {
      # The paho-mqtt test suite is currently broken under Python 3.14.
      # https://github.com/NixOS/nixpkgs/issues/542586
      paho-mqtt = previous.paho-mqtt.overridePythonAttrs {
        doCheck = false;
      };
    };
  };
  pythonPackages =
    hass.python3Packages or (hass.python.pkgs or hass.passthru.python.pkgs);

  matrixPassword = atlas.secrets.universe [
    "hass"
    "matrix"
  ];
in
{
  options.planet.hosting.home.enable = lib.mkEnableOption "Home Assistant";

  config = lib.mkIf home.enable {
    age.secrets.${matrixPassword} = {
      rekeyFile = ../../../.. + "/secrets/${matrixPassword}.age";
      owner = "hass";
      group = "hass";
      mode = "0400";
    };

    services.home-assistant = {
      enable = true;
      package = hass;
      openFirewall = true;

      extraComponents = [
        "analytics"
        "default_config"
        "esphome"
        "google_translate"
        "isal"
        "matrix"
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

      customComponents = import ./components {
        inherit pythonPackages lib pkgs;
      };

      config = {
        default_config = { };
        automation = "!include automations.yaml";

        matrix = {
          homeserver = "https://${atlas.hosting.matrix.host}";
          username = "@home:${domain}";
          password = "!include ${age.secrets.${matrixPassword}.path}";
          rooms = [ "!tC8V4rUjFO45Bs97U2:${domain}" ];
        };

        http = {
          server_host = listenAddress;
          server_port = port;
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
            "::1"
            atlas.mesh.subnet
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
                availability = ''
                  {{ is_number(states('sensor.solax_pv1_power'))
                     and is_number(states('sensor.solax_pv2_power'))
                     and is_number(states('sensor.solax_pv3_power')) }}
                '';
                state = ''
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
                availability = ''
                  {{ is_number(states('sensor.solax_battery_1_power'))
                     and is_number(states('sensor.solax_battery_2_power')) }}
                '';
                state = ''
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

    environment.etc."home-assistant/entities.jinja".source = ./entities.jinja;

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules.home = {
        ingress.host = host;
        upstream.http.url = "http://${proxyAddress}:${toString port}";
      };
    };
  };
}
