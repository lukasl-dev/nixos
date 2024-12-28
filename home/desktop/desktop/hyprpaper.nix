{
  services.hyprpaper = {
    enable = true;

    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [ "${../../../wallpapers/10.png}" ];
      wallpaper = [ ",${../../../wallpapers/10.png}" ];
    };
  };
}
