{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy) domain matrix;
in
{
  options.galaxy.matrix = {
    turn = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "turn.${domain}";
        readOnly = true;
      };

      secret = lib.mkOption {
        type = lib.types.str;
        default = "galaxy/matrix/turnSecret";
        readOnly = true;
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets.${matrix.turn.secret} = {
        rekeyFile = ../../../secrets/galaxy/matrix/turnSecret.age;
        mode = "0444";
      };
    }

    (lib.mkIf matrix.enable {
      galaxy.acme.extraCertificates.${matrix.turn.host}.reloadServices = [ "coturn.service" ];

      services.coturn = {
        enable = true;

        realm = domain;
        cert = "/var/lib/acme/${matrix.turn.host}/fullchain.pem";
        pkey = "/var/lib/acme/${matrix.turn.host}/key.pem";

        no-cli = true;

        use-auth-secret = true;
        static-auth-secret-file = age.secrets.${matrix.turn.secret}.path;

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
    })
  ];
}
