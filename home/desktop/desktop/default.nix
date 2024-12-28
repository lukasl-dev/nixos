{
  pkgs,
  ...
}:

# TODO: split this into smaller files

{
  imports = [
    ./hyprland.nix
    ./hyprpaper.nix
    ./waybar.nix
  ];

  # quick access
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
  };

  # notifications
  services.swaync = {
    enable = true;
    style = builtins.readFile ../../../dots/swaync/theme.css;
  };

  # auto mount removable drives
  services.udiskie.enable = true;

  # hyprcursor icons directory
  home.file.".icons" = {
    enable = true;
    source = "${pkgs.catppuccin-cursors.mochaLight}/share/icons/";
    target = ".icons";
  };

  # sunset
  services.wlsunset = {
    enable = true;
    sunrise = "06:00";
    sunset = "17:00";

    temperature = {
      day = 6500;
      night = 4500;
    };
  };

  home.packages = [
    # emoji quick access
    pkgs.bemoji

    # notifications
    pkgs.libnotify

    # screenshot
    pkgs.grim
    pkgs.hyprshot

    # clipboard
    pkgs.wl-clipboard
    pkgs.cliphist

    # hyprcursor
    pkgs.hyprcursor
    pkgs.catppuccin-cursors.mochaMauve

    # miscellaneous
    pkgs.xwaylandvideobridge
    pkgs.xdg-utils

    # wlsunset
    pkgs.wlsunset
  ];
}
