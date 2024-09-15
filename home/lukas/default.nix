{ pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./nvim

    ./apps.nix
    ./browser.nix
    ./catppuccin.nix
    ./development.nix
    ./gaming.nix
    ./shell.nix
    ./terminal.nix

    ./system/desktop/hyprland
    ./system/desktop/waybar
    ./system/desktop/dconf.nix
    ./system/desktop/dunst.nix
    ./system/desktop/gtk.nix
    ./system/desktop/rofi.nix

    ./system/utils/xdg
    ./system/utils/udiskie.nix
  ];

  programs.home-manager.enable = true;

  home = {
    stateVersion = "24.05";

    username = "lukas";
    homeDirectory = "/home/lukas";
    packages = import ./packages.nix { inherit pkgs pkgs-unstable; };
  };
}
