{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}:

{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin

    # ./ags
    ./alacritty
    ./bat
    ./btop
    ./bun
    ./carapace
    ./catppuccin
    ./chromium
    ./dconf
    ./dir-env
    ./dunst
    ./easyeffects
    ./fastfetch
    ./fzf
    #./gh
    ./git
    ./go
    ./gpg
    ./gtk
    ./hyprland
    ./mpv
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
  home.stateVersion = "24.05";

  home.username = "lukas";
  home.homeDirectory = "/home/lukas";
  home.packages = import ./packages.nix { inherit pkgs pkgs-unstable; };
}
