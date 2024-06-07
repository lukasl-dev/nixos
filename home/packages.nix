{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # utils
    wl-clipboard
    unzip
    zip
    xdg-utils

    # apps
    (vesktop.override { withSystemVencord = false; })

    # development
    devenv
    zig
    zulu
    nodejs
    bun
    go
    python3

    # cli
    btop
    fastfetch
    speedtest-cli

    # writing
    texliveFull
    obsidian

    # desktop
    swaybg
    dunst
    libnotify
    rofi-wayland

    # gaming
    lutris
    wineWowPackages.waylandFull
  ];

  fonts.packages = with pkgs; [
	  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}
