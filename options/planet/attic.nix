{
  config,
  lib,
  ...
}:

let
  domain = config.universe.domain;
  user = config.universe.user;

  attic = config.planet.attic;
in
{
  options.planet.attic = {
    enable = lib.mkEnableOption "Enable Attic binary cache";

    sops = {
      token = lib.mkOption {
        type = lib.types.str;
        description = "SOPS key for Attic client token";
      };
    };

    cache = lib.mkOption {
      type = lib.types.str;
      example = "vega";
      description = "Name of the Attic binary cache to use";
    };

    trusted-public-key = lib.mkOption {
      type = lib.types.str;
      example = "vega:B57uOXZgdBLi/6kEAnfmoIpIg+V8/RjLvxQI6iVCtO8=";
      description = "Attic binary cache public key";
    };
  };

  config = lib.mkIf attic.enable {
    nix.settings = {
      substituters = [
        "https://cache.${domain}/${attic.cache}"
      ];
      trusted-public-keys = [ attic.trusted-public-key ];
    };

    sops = {
      secrets.${attic.sops.token} = { };

      templates."planets/${config.planet.name}/attic/config" = {
        content = ''
          default-server = "attic"

          [servers.attic]
          endpoint = "https://cache.${domain}"
          token = "${config.sops.placeholder.${attic.sops.token}}"
        '';
        owner = user.name;
        path = "/home/${user.name}/.config/attic/config.toml";
      };
    };
  };
}
