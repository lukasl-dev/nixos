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
    ./dir-env
    ./dunst
    ./easyeffects
    ./fish
    ./fzf
    ./git
    ./go
    ./gpg
    ./gtk
    ./hyprland
    ./nushell
    ./nvim
    ./pass
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
    gh
    tree
    wl-clipboard
    ripgrep
    zoxide
    fastfetch
    speedtest-cli
    yt-dlp

    # easyeffects
    playerctl
    ffmpeg
    cliphist

    zip
    unzip

    zig
    nodejs
    zulu21
    gleam
    erlang
    elixir

    python3
    uv

    devenv
    just
    hyperfine

    texliveFull
    graphviz

    signal-desktop
    slack

    vesktop
    obsidian
    termius
    localsend
    
    prismlauncher
    lutris
    wineWowPackages.waylandFull
  ];
}
