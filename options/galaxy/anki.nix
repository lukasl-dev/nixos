{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy) anki;

  listenAddress = "127.0.0.1";

  password = "galaxy/anki/password";

  stateDir = "/var/lib/private/anki-sync-server";
in
{
  options.galaxy = {
    anki = {
      enable = lib.mkEnableOption "Enable Anki sync server";

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
      age.secrets.${password}.rekeyFile = ../../secrets/galaxy/anki/password.age;
    }

    (lib.mkIf anki.enable (
      lib.mkMerge [
        {
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
        }

        {
          galaxy = {
            proxy.rules = [
              {
                name = "anki";
                to.http = "http://${listenAddress}:${toString anki.port}";
              }
            ];
            backup.paths = [ stateDir ];
          };
        }
      ]
    ))
  ];
}
