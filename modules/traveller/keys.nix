{ config, lib, ... }:

let
  inherit (config) traveller;
in
{
  options.traveller.keys = {
    private = lib.mkOption {
      type = lib.types.str;
    };

    public = lib.mkOption {
      type = lib.types.str;
    };
  };

  config.traveller.modules = [
    {
      age.secrets.${traveller.keys.private} = {
        rekeyFile = ../.. + "/secrets/${traveller.keys.private}.age";
        owner = traveller.user.name;
        generator.script = "ssh-ed25519";
      };
    }
  ];
}
