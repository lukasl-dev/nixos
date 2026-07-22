{
  config,
  lib,
  ...
}:

let
  inherit (config) planet;

  keys = ../.. + "/secrets/planets/${planet.name}/keys";
  public = keys + "/public.pub";
in
{
  options.planet.keys = {
    private = lib.mkOption {
      type = lib.types.str;
      default = "planets/${planet.name}/keys/private";
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

  config.planet.modules = [
    {
      age.secrets.${planet.keys.private} = {
        rekeyFile = keys + "/private.age";
        generator.script = "unixverse-ssh-ed25519";
      };
    }
  ];
}
