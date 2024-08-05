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
    ./fastfetch
    ./fish
    ./fzf
    #./gh
    ./git
    ./go
    ./gpg
    ./gtk
    ./hyprland
    ./nushell
    ./nvim
    ./pass
    ./ranger
    ./ripgrep
    ./rofi
    ./sioyek
    ./texlive
    ./tmux
    ./udiskie
    ./waybar
    ./xdg
    ./yt-dlp
    ./zoxide
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.05"; # Please read the comment before changing.
  
  home.username = "lukas";
  home.homeDirectory = "/home/lukas";

  home.packages = with pkgs; [
    gh
    tree
    wl-clipboard
    speedtest-cli

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
