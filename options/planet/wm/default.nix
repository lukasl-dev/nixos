{
  config,
  lib,
  pkgs,
  ...
}:

let
  wm = config.planet.wm;
in
{
  imports = [
    ./waybar

    ./gtk.nix
    ./hyprland.nix
    ./qt.nix
    ./sddm.nix
  ];

  options.planet.wm = {
    enable = lib.mkEnableOption "Enable window management";
  };

  config = lib.mkIf wm.enable {
    environment.systemPackages = [ pkgs.zenity ];
  };
}
