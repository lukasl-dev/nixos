{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  gaming = config.planet.gaming;
in
{
  imports = [
    ./bottles.nix
    ./lutris.nix
    ./minecraft.nix
    ./r2modman.nix
    ./steam.nix
  ];

  options.planet.gaming = {
    enable = lib.mkEnableOption "Enable gaming options";
  };

  config = lib.mkIf gaming.enable {
    environment.systemPackages = [
      pkgs-unstable.gamescope
      pkgs-unstable.gamescope-wsi
      pkgs-unstable.protonplus
      pkgs-unstable.protonup-qt
      pkgs-unstable.gamemode
    ];

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 20;
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
  };
}
