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

  isGuest = matrix.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/private/tuwunel";
  registrationToken = "galaxy/lukasl-dev/matrix/registrationToken";

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

    networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ matrix.port ];
  };
in
{
  imports = [ ./turn.nix ];

  options.galaxy.lukasl-dev = {
    matrix = {
      enable = lib.mkEnableOption "Enable Matrix homeserver";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run the Matrix homeserver in the lukasl-dev container or on the host.";
      };

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
          rekeyFile = ../../../../secrets/galaxy/lukasl-dev/matrix/registrationToken.age;
          mode = "0444";
        };
      };
    }

    (lib.mkIf matrix.enable (
      lib.mkMerge [
        {
          galaxy.lukasl-dev = {
            proxy.rules = [
              {
                type = "https";
                name = "matrix";
                to.http = "http://${listenAddress}:${toString matrix.port}";
              }
              {
                type = "https";
                name = "matrix-well-known";
                from = {
                  host = domain;
                  pathPrefix = "/.well-known/matrix";
                };
                priority = 100;
                to.http = "http://${listenAddress}:${toString matrix.port}";
              }
            ];

            backup.paths = [
              (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
            ];

            bindMounts = lib.mkIf isGuest [ age.secrets.${registrationToken}.path ];

            modules.matrix = {
              inherit (matrix) mode;
              inherit module;
            };
          };
        }

        (lib.mkIf (!isGuest) module)
      ]
    ))
  ];
}
