{ pkgs, ... }:

{
  services.hyprpaper = {
    enable = true;

    settings = {
      ipc = "on";

      splash = false;
      splash_offset = 2.0;

      preload = [
        "~/nixos/wallpaper.png"
      ];

      wallpaper = [
        ",~/nixos/wallpaper.png"
      ];
    };
  };

  home.packages = with pkgs; [
    hyprshot
  ];
}
