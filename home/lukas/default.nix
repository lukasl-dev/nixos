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
    ./pass
    ./ranger
    ./sioyek
    ./texlive
    ./tmux
    ./waybar
    ./xdg

    ./alacritty.nix
    ./bat.nix
    ./btop.nix
    ./bun.nix
    ./carapace.nix
    ./nvim.nix
    ./ripgrep.nix
    ./rofi.nix
    ./udiskie.nix
    ./yt-dlp.nix
    ./zoxide.nix
  ];

  programs.home-manager.enable = true;

  home = {
    stateVersion = "24.05";

    username = "lukas";
    homeDirectory = "/home/lukas";
    packages = import ./packages.nix { inherit pkgs pkgs-unstable; };
  };
}
