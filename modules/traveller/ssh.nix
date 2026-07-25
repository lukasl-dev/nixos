{ config, lib, ... }:

let
  inherit (config) traveller;

  primePublicPath = ../../secrets/travellers/prime/keys/public.pub;
  primePublic =
    if builtins.pathExists primePublicPath then
      builtins.readFile primePublicPath
    else
      null;
in
{
  config.traveller.modules = [
    (
      { config, ... }:

      lib.mkIf (traveller.keys.public != null) {
        hjem.users.${traveller.user.name}.files = {
          ".ssh/id_ed25519.pub".text = traveller.keys.public;

          ".ssh/config".text = ''
            Host *
              IdentityFile ${config.age.secrets.${traveller.keys.private}.path}
          '';
        };

        users.users.${traveller.user.name} = {
          openssh.authorizedKeys.keys = lib.unique (
            [ traveller.keys.public ] ++ lib.optional (primePublic != null) primePublic
          );
        };
      }
    )
  ];
}
