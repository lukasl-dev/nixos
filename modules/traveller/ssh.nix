{ config, lib, ... }:

let
  inherit (config) traveller;

  publicKeyPath = ../../secrets + "/travellers/${traveller.name}/keys/public.pub";
  primePublicPath = ../../secrets/travellers/prime/keys/public.pub;
  primePublic =
    if builtins.pathExists primePublicPath then builtins.readFile primePublicPath else null;
in
{
  config.traveller.modules = [
    (
      { config, ... }:

      lib.mkIf (traveller.keys.public != null) {
        hjem.users.${traveller.user.name}.files = {
          ".ssh/id_ed25519" = {
            source = config.age.secrets.${traveller.keys.private}.path;
            clobber = true;
          };

          ".ssh/id_ed25519.pub" = {
            source = publicKeyPath;
            clobber = true;
          };

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
