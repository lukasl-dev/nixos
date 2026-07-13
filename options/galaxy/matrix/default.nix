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

  inherit (config.galaxy) domain matrix;

  listenAddress = "127.0.0.1";
  stateDir = "/var/lib/private/tuwunel";

  registrationToken = "galaxy/matrix/registrationToken";

  module = {
    services.matrix-tuwunel = {
      enable = true;
      package = inputs.tuwunel.packages.${system}.default;
      settings = {
        global = {
          server_name = domain;
          address = [ listenAddress ];
          port = [ matrix.port ];

          allow_registration = true;
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

  };
in
{
  imports = [ ./turn.nix ];

  options.galaxy = {
    matrix = {
      enable = lib.mkEnableOption "Enable Matrix homeserver";

      port = lib.mkOption {
        type = lib.types.port;
        default = 6167;
        readOnly = true;
        description = "Port for the Matrix homeserver.";
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets = {
        ${registrationToken} = {
          rekeyFile = ../../../secrets/galaxy/matrix/registrationToken.age;
          mode = "0444";
        };
      };
    }

    (lib.mkIf matrix.enable (
      lib.mkMerge [
        module
        {
          galaxy = {
            proxy.rules = [
              {
                name = "matrix";
                to.http = "http://${listenAddress}:${toString matrix.port}";
              }
              {
                name = "matrix-well-known";
                from = {
                  host = domain;
                  pathPrefix = "/.well-known/matrix";
                };
                priority = 100;
                to.http = "http://${listenAddress}:${toString matrix.port}";
              }
            ];
            backup.paths = [ stateDir ];
          };
        }
      ]
    ))
  ];
}
