{
  atlas,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) domain;
  inherit (config.planet.hosting) matrix;
  inherit (atlas.hosting.matrix) host;
  inherit (pkgs.stdenv.hostPlatform) system;

  listenAddress = "127.0.0.1";
  port = 6167;
  stateDir = "/var/lib/private/tuwunel";

  registrationToken = atlas.secrets.universe [
    "matrix"
    "registrationToken"
  ];
  turnSecret = atlas.secrets.universe [
    "matrix"
    "turnSecret"
  ];
in
{
  imports = [
    ./turn.nix
    ./whatsapp.nix
  ];

  options.planet.hosting.matrix.enable = lib.mkEnableOption "Matrix homeserver";

  config = lib.mkIf matrix.enable {
    age.secrets.${registrationToken} = {
      rekeyFile = ../../../.. + "/secrets/${registrationToken}.age";
      mode = "0444";
    };

    services.matrix-tuwunel = {
      enable = true;
      package = inputs.tuwunel.packages.${system}.default;

      settings.global = {
        server_name = domain;
        address = [ listenAddress ];
        port = [ port ];

        allow_registration = true;
        registration_token_file = age.secrets.${registrationToken}.path;

        turn_uris = [
          "turn:${atlas.hosting.turn.host}?transport=udp"
          "turn:${atlas.hosting.turn.host}?transport=tcp"
          "turns:${atlas.hosting.turn.host}?transport=tcp"
        ];
        turn_secret_file = age.secrets.${turnSecret}.path;

        well_known = {
          client = "https://${host}";
          server = "${host}:443";
        };

        url_preview_domain_contains_allowlist = [ "*" ];
        url_preview_check_root_domain = true;
      };
    };

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules = {
        matrix = {
          ingress.host = host;
          upstream.http.url = "http://${listenAddress}:${toString port}";
        };

        matrix-well-known = {
          ingress = {
            host = domain;
            http.path.prefix = "/.well-known/matrix";
          };
          upstream.http.url = "http://${listenAddress}:${toString port}";
        };
      };
    };
  };
}
