{ pkgs, inputs, ... }:

{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin

    # ./ags
    ./alacritty
    ./bat
    ./btop
    ./bun
    ./catppuccin
    ./chromium
    ./dunst
    ./fzf
    ./git
    ./gtk
    ./hyprland
    ./nushell
    ./nvim
    ./ranger
    ./rofi
    ./sioyek
    ./tmux
    ./waybar
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

    playerctl
    ffmpeg

    zig
    nodejs
    go
    zulu21
    gleam

    python3
    uv

    devenv
    just

    texliveFull
    graphviz

    signal-desktop
    slack

    vesktop
    obsidian
    termius
    
    prismlauncher
    lutris
    wineWowPackages.waylandFull
  ];
}
