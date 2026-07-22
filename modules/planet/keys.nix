{
  config,
  lib,
  atlas,
  ...
}:

let
  inherit (config) planet;
in
{
  options.planet.keys = {
    private = lib.mkOption {
      type = lib.types.str;
      default = atlas.secrets.planet [
        "keys"
        "private"
      ];
    };

    public = lib.mkOption {
      type = lib.types.str;
    };
  };

  config.planet.modules = [
    {
      age.secrets.${planet.keys.private} = {
        rekeyFile = ../.. + "/secrets/${planet.keys.private}.age";
        generator.script = "ssh-ed25519";
      };
    }
  ];
}
