{ config, lib, ... }:

let
  inherit (config) traveller;
in
{
  config.traveller.modules = [
    (
      { config, ... }:

      {
        hjem.users.${traveller.user.name}.files = {
          ".ssh/id_ed25519.pub".text = traveller.keys.public;

          ".ssh/config".text = ''
            Host *
              IdentityFile ${config.age.secrets.${traveller.keys.private}.path}
          '';
        };

        users.users.${traveller.user.name} = {
          openssh.authorizedKeys.keys = lib.unique [
            traveller.keys.public
            (builtins.readFile ../../travellers/prime/id_ed25519.pub)
          ];
        };
      }
    )
  ];
}
