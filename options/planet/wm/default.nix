{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) wm;
in
{
  imports = [
    ./noctalia.nix
    ./gtk.nix
    ./hyprland.nix
    ./qt.nix
    ./sddm.nix
  ];

  options.planet.wm = {
    enable = lib.mkEnableOption "Enable window management";

    display = lib.mkOption {
      type = lib.types.enum [
        "wayland"
        "x11"
      ];
      readOnly = true;
      description = "Display protocol";
    };
  };

  config = lib.mkMerge [
    {
      planet.wm.display = if config.planet.wm.hyprland.enable then "wayland" else "x11";
    }
    (lib.mkIf wm.enable {
      environment.systemPackages = [ pkgs.zenity ];
    })
  ];
}
