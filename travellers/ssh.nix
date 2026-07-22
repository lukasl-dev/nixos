{ config, lib, ... }:

let
  inherit (config) age traveller;
in
{
  config.traveller.modules = [
    {
      hjem.users.${traveller.user.name}.files = {
        ".ssh/id_ed25519.pub".text = traveller.keys.public;

        ".ssh/config".text = ''
          Host *
            IdentityFile ${age.secrets.${traveller.keys.private}.path}
        '';
      };

      users.users.${traveller.user.name} = {
        openssh.authorizedKeys.keys = lib.unique [
          traveller.keys.public
          (builtins.readFile ./prime/id_ed25519.pub)
        ];
      };
    }
  ];
}
