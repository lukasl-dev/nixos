{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;
in
{
  config = lib.mkIf hyprland.enable {
    planet.display.hyprland.bind = [
      {
        keys = "SUPER + S";
        dispatcher.execCmd = ''grim -g "$(slurp -d)" - | wl-copy'';
      }
      {
        keys = "SUPER + SHIFT + S";
        dispatcher.execCmd = "hyprshot -m window -m active --clipboard-only";
      }
    ];

    environment.systemPackages = with pkgs; [
      grim
      slurp
      hyprshot
    ];
  };
}
