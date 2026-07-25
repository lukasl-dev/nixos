{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;

  inherit (atlas.hosting.cache) host;

  token = atlas.secrets.universe [
    "attic"
    "token"
  ];
  netrc = atlas.secrets.universe [
    "attic"
    "netrc"
  ];
in
{
  age.secrets = {
    ${token} = {
      rekeyFile = ../.. + "/secrets/${token}.age";
      intermediary = true;
    };

    ${netrc} = {
      rekeyFile = ../.. + "/secrets/${netrc}.age";
      mode = "0400";

      generator = {
        dependencies.token = age.secrets.${token};
        script =
          {
            decrypt,
            deps,
            pkgs,
            ...
          }:
          ''
            token="$(
              ${decrypt} "${deps.token.file}" \
                | ${pkgs.coreutils}/bin/tr -d '\r\n'
            )"

            printf 'machine %s\n' ${lib.escapeShellArg host}
            printf 'password %s\n' "$token"
          '';
      };
    };
  };

  environment.systemPackages = [ pkgs.unstable.attic-client ];

  nix.settings = {
    extra-substituters = [ "https://${host}/universe" ];
    extra-trusted-public-keys = [
      "universe:w0jdMOE2LZ74t2WSja4jKaMBPzai2aVM/VuBzszi0BQ="
    ];
    netrc-file = age.secrets.${netrc}.path;
  };
}
