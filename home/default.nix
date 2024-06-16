{ pkgs, ... }:

{
  imports = [
    ./ags
    ./alacritty
    ./chromium
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
    tree
    wl-clipboard
    ripgrep
    zoxide

    neovim
    vesktop
  ];
}
