{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) domain addresses waka;

  isGuest = waka.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/private/wakapi";
  salt = "galaxy/lukasl-dev/waka/salt";

  module = {
    services.wakapi = {
      enable = true;

      passwordSaltFile = age.secrets.${salt}.path;

      settings = {
        server = {
          public_url = "https://waka.${domain}";
          listen_ipv4 = listenAddress;
          inherit (waka) port;
        };

        security = {
          insecure_cookies = false;
          allow_signup = false;
        };
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ waka.port ];
  };
in
{
  options.galaxy.lukasl-dev = {
    waka = {
      enable = lib.mkEnableOption "Enable wakapi server";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run wakapi in the lukasl-dev container or on the host.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        readOnly = true;
        description = "Port for the wakapi server.";
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets.${salt} = {
        rekeyFile = ../../../secrets/galaxy/lukasl-dev/waka/salt.age;
        mode = "0444";
      };
    }

    (lib.mkIf waka.enable (
      lib.mkMerge [
        {
          galaxy.lukasl-dev = {
            proxy.rules = [
              {
                type = "https";
                name = "waka";
                to.http = "http://${listenAddress}:${toString waka.port}";
              }
            ];

            backup.paths = [
              (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
            ];

            bindMounts = lib.mkIf isGuest [ age.secrets.${salt}.path ];

            modules.waka = {
              inherit (waka) mode;
              inherit module;
            };
          };
        }

        (lib.mkIf (!isGuest) module)
      ]
    ))
  ];
}
