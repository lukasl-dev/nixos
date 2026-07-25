{ config, lib, ... }:

let
  inherit (config) traveller;

  keys = ../.. + "/secrets/travellers/${traveller.name}/keys";
  public = keys + "/public.pub";
in
{
  options.traveller.keys = {
    private = lib.mkOption {
      type = lib.types.str;
      default = "travellers/${traveller.name}/keys/private";
      readOnly = true;
      internal = true;
    };

    public = lib.mkOption {
      type = with lib.types; nullOr str;
      default = if builtins.pathExists public then builtins.readFile public else null;
      readOnly = true;
      internal = true;
    };
  };

  config.traveller.modules = [
    {
      assertions = [
        {
          assertion = traveller.keys.public != null;
          message = ''
            Missing public key for traveller ${traveller.name}. Run:

              nix run .#traveller-keygen -- ${traveller.name}
          '';
        }
      ];

      age.secrets.${traveller.keys.private} = {
        rekeyFile = keys + "/private.age";
        owner = traveller.user.name;
        generator.script = "unixverse-ssh-ed25519";
      };
    }
  ];
}
