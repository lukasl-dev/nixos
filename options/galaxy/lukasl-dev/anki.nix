{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) addresses anki;
in
{
  options.galaxy.lukasl-dev = {
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

  config = lib.mkIf anki.enable (
    let
      password = "galaxy/lukasl-dev/anki/password";
    in
    {
      age.secrets.${password} = {
        rekeyFile = ../../../secrets/galaxy/lukasl-dev/anki/password.age;
      };

      galaxy.lukasl-dev = {
        proxy.rules = [
          {
            type = "https";
            name = "anki";
            to.http = "http://${addresses.local}:${toString anki.port}";
          }
        ];

        bindMounts = [ age.secrets.${password}.path ];

        modules = [
          {
            services.anki-sync-server = {
              enable = true;

              address = addresses.local;
              inherit (anki) port;

              users = [
                {
                  username = "lukas";
                  passwordFile = age.secrets.${password}.path;
                }
              ];
            };

            networking.firewall.allowedTCPPorts = [ anki.port ];
          }
        ];
      };

    }
  );
}
