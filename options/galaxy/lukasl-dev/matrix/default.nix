{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (pkgs.stdenv.hostPlatform) system;

  inherit (config.galaxy.lukasl-dev) domain addresses matrix;
in
{
  imports = [ ./turn.nix ];

  options.galaxy.lukasl-dev = {
    matrix = {
      enable = lib.mkEnableOption "Enable Anki sync server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 6167;
        readOnly = true;
        description = "Port for the Anki sync server.";
      };
    };
  };

  config = lib.mkIf matrix.enable (
    let
      registrationToken = "galaxy/lukasl-dev/matrix/registrationToken";
    in
    {
      age.secrets = {
        ${registrationToken} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/matrix/registrationToken.age;
        };
      };

      galaxy.lukasl-dev = {
        proxy.rules = [
          {
            type = "https";
            name = "matrix";
            to.http = "http://${addresses.local}:${toString matrix.port}";
          }
          {
            type = "https";
            name = "matrix-well-known";
            from = {
              host = domain;
              pathPrefix = "/.well-known/matrix";
            };
            priority = 100;
            to.http = "http://${addresses.local}:${toString matrix.port}";
          }
        ];

        bindMounts = [ age.secrets.${registrationToken}.path ];

        modules = [
          {
            services.matrix-tuwunel = {
              enable = true;
              package = inputs.tuwunel.packages.${system}.default;
              settings = {
                global = {
                  server_name = domain;
                  address = [ addresses.local ];
                  port = [ matrix.port ];

                  allow_registration = false;
                  registration_token_file = age.secrets.${registrationToken}.path;

                  turn_uris = [
                    "turn:${matrix.turn.host}?transport=udp"
                    "turn:${matrix.turn.host}?transport=tcp"
                    "turns:${matrix.turn.host}?transport=tcp"
                  ];
                  turn_secret_file = age.secrets.${matrix.turn.secret}.path;

                  well_known = {
                    client = "https://matrix.${domain}";
                    server = "matrix.${domain}:443";
                  };

                  url_preview_domain_contains_allowlist = [ "*" ];
                  url_preview_check_root_domain = true;
                };
              };
            };

            networking.firewall.allowedTCPPorts = [ matrix.port ];
          }
        ];
      };
    }
  );
}
