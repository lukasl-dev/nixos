{
  services.hyprpaper = {
    enable = true;

    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [
        "~/nixos/wallpapers/9.png"
      ];
      wallpaper = [
        ",~/nixos/wallpapers/9.png"
      ];
    };
  };
}
