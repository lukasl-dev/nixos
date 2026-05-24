{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) domain matrix;
in
{
  options.galaxy.lukasl-dev.matrix = {
    turn = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "turn.${domain}";
        readOnly = true;
      };

      secret = lib.mkOption {
        type = lib.types.str;
        default = "galaxy/lukasl-dev/matrix/turnSecret";
        readOnly = true;
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets.${matrix.turn.secret} = {
        rekeyFile = ../../../../secrets/galaxy/lukasl-dev/matrix/turnSecret.age;
        mode = "0444";
      };
    }

    (lib.mkIf matrix.enable {
      galaxy = {
        acme.domains.${domain} = {
          hosts = [ matrix.turn.host ];
          reloadServices = [ "coturn.service" ];
        };

        lukasl-dev.bindMounts = [
          age.secrets.${matrix.turn.secret}.path
          "/var/lib/acme/${matrix.turn.host}/fullchain.pem"
          "/var/lib/acme/${matrix.turn.host}/key.pem"
        ];
      };

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
