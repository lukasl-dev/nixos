{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) addresses anki;

  isGuest = anki.mode == "guest";

  password = "galaxy/lukasl-dev/anki/password";
  listenAddress = if anki.mode == "guest" then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/private/anki-sync-server";

  module = {
    services.anki-sync-server = {
      enable = true;

      address = listenAddress;
      inherit (anki) port;

      users = [
        {
          username = "lukas";
          passwordFile = age.secrets.${password}.path;
        }
      ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ anki.port ];
  };
in
{
  options.galaxy.lukasl-dev = {
    anki = {
      enable = lib.mkEnableOption "Enable Anki sync server";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run the Anki sync server in the lukasl-dev container or on the host.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 27701;
        readOnly = true;
        description = "Port for the Anki sync server.";
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets.${password} = {
        rekeyFile = ../../../secrets/galaxy/lukasl-dev/anki/password.age;
      };
    }

    (lib.mkIf anki.enable {
      galaxy.lukasl-dev = {
        proxy.rules = [
          {
            type = "https";
            name = "anki";
            to.http = "http://${listenAddress}:${toString anki.port}";
          }
        ];

        backup.paths = [
          (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
        ];

        bindMounts = lib.mkIf isGuest [ age.secrets.${password}.path ];

        modules.anki = {
          inherit (anki) mode;
          inherit module;
        };
      };
    })

    (lib.mkIf (anki.enable && !isGuest) module)
  ];
}
