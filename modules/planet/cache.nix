{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age planet;

  inherit (atlas.hosting.cache) host;
  cache = "universe";
  endpoint = "https://${host}";
  publicKey = "universe:w0jdMOE2LZ74t2WSja4jKaMBPzai2aVM/VuBzszi0BQ=";

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
    extra-substituters = [ "${endpoint}/${cache}" ];
    extra-trusted-public-keys = [ publicKey ];
    netrc-file = age.secrets.${netrc}.path;
  };
}
