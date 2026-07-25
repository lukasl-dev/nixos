{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet.hosting) anki;
  inherit (atlas.hosting.anki) host;

  steward = atlas.travellers.eval config.planet.steward.traveller;

  listenAddress = "127.0.0.1";
  port = 27701;
  stateDir = "/var/lib/private/anki-sync-server";

  password = atlas.secrets.universe [
    "anki"
    "password"
  ];
in
{
  options.planet.hosting.anki.enable = lib.mkEnableOption "Anki sync server";

  config = lib.mkIf anki.enable {
    age.secrets.${password} = {
      rekeyFile = ../../.. + "/secrets/${password}.age";
      mode = "0400";
    };

    services.anki-sync-server = {
      enable = true;
      address = listenAddress;
      inherit port;

      users = [
        {
          username = steward.user.name;
          passwordFile = age.secrets.${password}.path;
        }
      ];
    };

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules.anki = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
