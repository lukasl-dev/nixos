{ pkgs, ... }:

{
  imports = [
    ./ags
    ./alacritty
    ./chromium
    ./git
    ./gtk
    ./hyprland
    ./nushell
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
    btop
    speedtest-cli
    yt-dlp

    zig
    bun
    nodejs
    go
    python3

    texliveFull
    graphviz

    signal-desktop
    slack

    neovim
    vesktop
    obsidian
  ];
}
