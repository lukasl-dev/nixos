{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (config.universe) user;

  inherit (config.planet) wm;
  inherit (config.planet.programs) jellyfin;
in
{
  options.planet.programs.jellyfin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable jellyfin";
    };
  };

  config = lib.mkIf jellyfin.enable {
    environment.systemPackages = [ pkgs.unstable.jellyfin-tui ];

    sops = {
      secrets = {
        "universe/jellyfin/server".owner = user.name;
        "universe/jellyfin/username".owner = user.name;
        "universe/jellyfin/password".owner = user.name;
      };

      templates."universe/jellyfin/tui/config" = {
        owner = user.name;
        path = "/home/${user.name}/.config/jellyfin-tui/config.yaml";
        content =
          let
            ph = config.sops.placeholder;
          in
          ''
            servers:
            - name: home
              password: ${ph."universe/jellyfin/password"}
              url: ${ph."universe/jellyfin/server"}
              username: ${ph."universe/jellyfin/username"}
          '';
      };
    };
  };
}
