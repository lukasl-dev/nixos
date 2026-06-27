{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) gaming display;
in
{
  imports = [
    ./minecraft.nix
    ./r2modman.nix
    ./steam.nix
  ];

  options = {
    planet.gaming = {
      enable = lib.mkEnableOption "Enable Hyprland";
    };
  };

  config = lib.mkIf gaming.enable {
    environment.systemPackages = [
      pkgs.winetricks
      (lib.mkIf (display.type == "wayland") pkgs.wineWow64Packages.waylandFull)

      pkgs.unstable.gamescope
      pkgs.unstable.gamescope-wsi
      pkgs.unstable.protonplus
      pkgs.unstable.protonup-qt
      pkgs.unstable.gamemode
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

    programs.gamescope = {
      enable = true;

      package = pkgs.gamescope.overrideAttrs (old: {
        NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or [ ]) ++ [ "-fno-fast-math" ];
      });
    };
  };
}
