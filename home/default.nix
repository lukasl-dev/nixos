{ pkgs, inputs, ... }:

{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin

    ./ags
    ./alacritty
    ./btop
    ./bun
    ./chromium
    ./dunst
    ./git
    ./gtk
    ./hyprland
    ./nushell
    ./nvim
    ./xdg
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.05"; # Please read the comment before changing.
  
  home.username = "lukas";
  home.homeDirectory = "/home/lukas";

  home.packages = with pkgs; [
    git
    gh
    tree
    wl-clipboard
    ripgrep
    zoxide
    fastfetch
    speedtest-cli
    yt-dlp

    zig
    nodejs
    go
    python3
    zulu21

    devenv

    texliveFull
    graphviz

    signal-desktop
    slack

    vesktop
    obsidian
    termius
    
    bemoji

    prismlauncher
    lutris
    wineWowPackages.waylandFull
  ];
}
