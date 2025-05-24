{
  pkgs,
  ...
}:

# TODO: split this into smaller files

{
  imports = [
    ../../../homeModules/desktop/wayland/hyprland.nix

    ../../../homeModules/desktop/wayland/waybar
    ../../../homeModules/desktop/wayland/wlsunset.nix

    ../../../homeModules/desktop/rofi
    ../../../homeModules/desktop/wpaperd.nix
    ../../../homeModules/desktop/swaync.nix
    ../../../homeModules/desktop/zenity.nix
  ];

  # auto mount removable drives
  services.udiskie.enable = true;

  # hyprcursor icons directory
  home.file.".icons" = {
    enable = true;
    source = "${pkgs.catppuccin-cursors.mochaLight}/share/icons/";
    target = ".icons";
  };

  home.packages = [
    # notifications
    pkgs.libnotify

    # screenshot
    pkgs.grim
    pkgs.slurp
    pkgs.hyprshot

    # clipboard
    pkgs.wl-clipboard
    pkgs.clipse

    # hyprcursor
    pkgs.hyprcursor
    pkgs.catppuccin-cursors.mochaMauve

    # miscellaneous
    # pkgs.xwaylandvideobridge
    pkgs.xdg-utils
  ];
}
