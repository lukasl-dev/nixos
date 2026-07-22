{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (config) planet;
in
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  age = {
    generators.unixverse-ssh-ed25519 =
      {
        lib,
        name,
        pkgs,
        ...
      }:
      ''
        directory="$(${pkgs.coreutils}/bin/mktemp -d)"
        trap '${pkgs.coreutils}/bin/rm -rf "$directory"' EXIT

        ${pkgs.openssh}/bin/ssh-keygen \
          -q \
          -t ed25519 \
          -N "" \
          -C ${lib.escapeShellArg "unixverse:${name}"} \
          -f "$directory/private"

        ${pkgs.coreutils}/bin/cat "$directory/private"
      '';

    identityPaths = [ "/etc/agenix/identity" ];

    rekey = {
      masterIdentities = [ "/etc/agenix/identity" ];
      storageMode = "local";
      localStorageDir = ../.. + "/secrets/_/${planet.name}";
    }
    // lib.optionalAttrs (planet.keys.public != null) {
      hostPubkey = planet.keys.public;
    };
  };
}
