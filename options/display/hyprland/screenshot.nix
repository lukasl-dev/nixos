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
    planet.display.hyprland.lua = [
      # lua
      ''
        hl.bind("SUPER + S", hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | wl-copy"))
        hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m window -m active --clipboard-only"))
      ''
    ];

    environment.systemPackages = with pkgs; [
      grim
      slurp
      hyprshot
    ];
  };
}
