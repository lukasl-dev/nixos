{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) domain;
  inherit (config.planet.hosting) matrix proxy;
  inherit (atlas.hosting.turn) host;

  secret = atlas.secrets.universe [
    "matrix"
    "turnSecret"
  ];
in
{
  config = lib.mkIf matrix.enable {
    age.secrets.${secret} = {
      rekeyFile = ../../../.. + "/secrets/${secret}.age";
      mode = "0444";
    };

    security.acme.certs = lib.mkIf proxy.enable {
      ${host}.reloadServices = [ "coturn.service" ];
    };

    services.coturn = {
      enable = true;

      realm = domain;
      cert = "/var/lib/acme/${host}/fullchain.pem";
      pkey = "/var/lib/acme/${host}/key.pem";

      no-cli = true;
      use-auth-secret = true;
      static-auth-secret-file = age.secrets.${secret}.path;

      min-port = 52000;
      max-port = 55000;
      extraConfig = ''
        fingerprint
        no-multicast-peers
      '';
    };

    users.users.turnserver.extraGroups = [ "acme" ];

    networking.firewall = {
      allowedTCPPorts = [
        3478
        5349
      ];
      allowedUDPPorts = [ 3478 ];
      allowedUDPPortRanges = [
        {
          from = 52000;
          to = 55000;
        }
      ];
    };
  };
}
